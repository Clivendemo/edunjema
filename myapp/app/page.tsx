'use client'

import React, { useState } from 'react'

export default function HomePage() {
  const [form, setForm] = useState({
    type: 'lesson_plan',
    syllabus: 'CBC',
    grade: '',
    subject: '',
    strandTopic: '',
    substrandSubtopic: '',
    numberOfStudents: '',
    lessonTimeMinutes: '',
  })

  const [result, setResult] = useState('')
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
    const { name, value } = e.target
    setForm({ ...form, [name]: value })
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)
    setError('')
    setResult('')

    try {
      const res = await fetch('/api/generate-content', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          ...form,
          numberOfStudents: Number(form.numberOfStudents),
          lessonTimeMinutes: Number(form.lessonTimeMinutes),
        }),
      })

      const data = await res.json()
      if (!res.ok) {
        setError(data.error || 'An error occurred.')
      } else {
        setResult(data.content)
      }
    } catch (err) {
      setError('Network error. Please try again.')
    } finally {
      setLoading(false)
    }
  }

  return (
    <main className="p-6 max-w-2xl mx-auto">
      <h1 className="text-2xl font-bold mb-4">Generate Lesson Plans or Notes</h1>

      <form onSubmit={handleSubmit} className="space-y-4">
        <div>
          <label>Type:</label>
          <select name="type" value={form.type} onChange={handleChange} className="border p-2 w-full">
            <option value="lesson_plan">Lesson Plan</option>
            <option value="notes">Notes</option>
          </select>
        </div>

        <div>
          <label>Syllabus:</label>
          <select name="syllabus" value={form.syllabus} onChange={handleChange} className="border p-2 w-full">
            <option value="CBC">CBC</option>
            <option value="8-4-4">8-4-4</option>
          </select>
        </div>

        <input name="grade" placeholder="Grade or Form" value={form.grade} onChange={handleChange} className="border p-2 w-full" />
        <input name="subject" placeholder="Subject" value={form.subject} onChange={handleChange} className="border p-2 w-full" />
        <input name="strandTopic" placeholder="Strand / Topic" value={form.strandTopic} onChange={handleChange} className="border p-2 w-full" />
        <input name="substrandSubtopic" placeholder="Substrand / Subtopic" value={form.substrandSubtopic} onChange={handleChange} className="border p-2 w-full" />
        {form.type === 'lesson_plan' && (
          <>
            <input name="numberOfStudents" type="number" placeholder="Number of Students" value={form.numberOfStudents} onChange={handleChange} className="border p-2 w-full" />
            <input name="lessonTimeMinutes" type="number" placeholder="Lesson Duration (minutes)" value={form.lessonTimeMinutes} onChange={handleChange} className="border p-2 w-full" />
          </>
        )}
        <button type="submit" disabled={loading} className="bg-blue-600 text-white px-4 py-2 rounded">
          {loading ? 'Generating...' : 'Generate'}
        </button>
      </form>

      {error && <p className="text-red-500 mt-4">{error}</p>}
      {result && (
        <div className="mt-6 bg-gray-100 p-4 rounded whitespace-pre-wrap">
          <h2 className="text-lg font-semibold mb-2">Generated Content:</h2>
          {result}
        </div>
      )}
    </main>
  )
}
