import { generateText } from "ai"
import { createOpenAI } from "@ai-sdk/openai" // MODIFIED: Import createOpenAI
import { type NextRequest, NextResponse } from "next/server"

// Define allowed origins for CORS. In production, replace '*' with your Flutter app's domain.
const allowedOrigin = process.env.NEXT_PUBLIC_API_URL || "http://myapp-mu-six.vercel.app/api/generate-content"

// NEW: Create an OpenAI client instance with the API key
const openai = createOpenAI({
  apiKey: process.env.OPENAI_API_KEY,
})

// Helper function to set CORS headers
function setCorsHeaders(response: NextResponse) {
  response.headers.set("Access-Control-Allow-Origin", allowedOrigin)
  response.headers.set("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
  response.headers.set("Access-Control-Allow-Headers", "Content-Type, Authorization")
  response.headers.set("Access-Control-Max-Age", "86400") // Cache preflight for 24 hours
}

// Handle OPTIONS requests (preflight requests for CORS)
export async function OPTIONS() {
  const response = new NextResponse(null, { status: 204 }) // 204 No Content for successful preflight
  setCorsHeaders(response)
  return response
}

export async function POST(req: NextRequest) {
  const response = new NextResponse() // Create a response object to modify headers

  try {
    const { type, syllabus, grade, subject, strandTopic, substrandSubtopic, numberOfStudents, lessonTimeMinutes } =
      await req.json()

    if (!type || !syllabus || !grade || !subject || !strandTopic || !substrandSubtopic) {
      setCorsHeaders(response)
      return NextResponse.json({ error: "Missing required parameters for content generation." }, { status: 400 })
    }

    let prompt: string
    let systemMessage: string
    let maxTokens: number

    if (type === "lesson_plan") {
      if (typeof numberOfStudents !== "number" || typeof lessonTimeMinutes !== "number") {
        setCorsHeaders(response)
        return NextResponse.json(
          { error: "Missing required parameters for lesson plan generation: numberOfStudents, lessonTimeMinutes." },
          { status: 400 },
        )
      }

      if (syllabus === "CBC") {
        prompt =
          `Generate a detailed CBC lesson plan for Grade ${grade}, Subject: ${subject}, Strand: ${strandTopic}, Substrand: ${substrandSubtopic}. ` +
          `Include: Key Inquiry Question, Core Competencies, Values, PCI links. ` +
          `Structure: Introduction (5 mins), Lesson Development (${lessonTimeMinutes - 10} mins), Conclusion (5 mins). ` +
          `Number of students: ${numberOfStudents}. Lesson time: ${lessonTimeMinutes} minutes. ` +
          `Ensure the plan is comprehensive and suitable for Kenyan education context.` +
          `The output should be a well-formatted text, suitable for direct display.`
      } else {
        // 8-4-4 Syllabus
        prompt =
          `Generate a detailed 8-4-4 lesson plan for Form ${grade}, Subject: ${subject}, Topic: ${strandTopic}, Subtopic: ${substrandSubtopic}. ` +
          `Include: Objectives, Introduction (5 mins), Lesson Development (${lessonTimeMinutes - 10} mins), Conclusion (5 mins). ` +
          `Number of students: ${numberOfStudents}. Lesson time: ${lessonTimeMinutes} minutes. ` +
          `Ensure the plan is comprehensive and suitable for Kenyan education context.` +
          `The output should be a well-formatted text, suitable for direct display.`
      }
      systemMessage =
        "You are a helpful assistant for Kenyan teachers, specializing in generating lesson plans for CBC and 8-4-4 syllabuses."
      maxTokens = 1000
    } else if (type === "notes") {
      if (syllabus === "CBC") {
        prompt =
          `Generate comprehensive notes for Grade ${grade}, Subject: ${subject}, Strand: ${strandTopic}, Substrand: ${substrandSubtopic}, based on the CBC syllabus. ` +
          `Ensure the notes are detailed, accurate, and suitable for Kenyan students.` +
          `The output should be a well-formatted text, suitable for direct display.`
      } else {
        // 8-4-4 Syllabus
        prompt =
          `Generate comprehensive notes for Form ${grade}, Subject: ${subject}, Topic: ${strandTopic}, Subtopic: ${substrandSubtopic}, based on the 8-4-4 syllabus. ` +
          `Ensure the notes are detailed, accurate, and suitable for Kenyan students.` +
          `The output should be a well-formatted text, suitable for direct display.`
      }
      systemMessage =
        "You are a helpful assistant for Kenyan teachers, specializing in generating educational notes for CBC and 8-4-4 syllabuses."
      maxTokens = 1500
    } else {
      setCorsHeaders(response)
      return NextResponse.json(
        { error: 'Invalid content type specified. Must be "lesson_plan" or "notes".' },
        { status: 400 },
      )
    }

    const { text } = await generateText({
      model: openai("gpt-4o"), // MODIFIED: Use the 'openai' instance created above
      prompt: prompt,
      system: systemMessage,
      maxTokens: maxTokens,
      temperature: 0.7,
    })

    if (!text) {
      setCorsHeaders(response)
      return NextResponse.json({ error: "OpenAI did not return any content." }, { status: 500 })
    }

    const successResponse = NextResponse.json({ content: text })
    setCorsHeaders(successResponse)
    return successResponse
  } catch (error: unknown) {
    console.error("Error calling OpenAI API:", error)
    let errorMessage = "An unknown error occurred."
    if (error instanceof Error) {
      errorMessage = error.message
    } else if (typeof error === "string") {
      errorMessage = error
    } else if (typeof error === "object" && error !== null) {
      const potentialError = error as { message?: unknown }
      if (typeof potentialError.message === "string") {
        errorMessage = potentialError.message
      }
    }
    const errorResponse = NextResponse.json(
      { error: "Failed to generate content from OpenAI.", details: errorMessage },
      { status: 500 },
    )
    setCorsHeaders(errorResponse)
    return errorResponse
  }
}
