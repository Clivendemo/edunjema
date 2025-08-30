#!/bin/bash

echo "Deploying Firestore security rules..."

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo "Firebase CLI is not installed. Please install it first:"
    echo "npm install -g firebase-tools"
    exit 1
fi

# Check if user is logged in
if ! firebase projects:list &> /dev/null; then
    echo "Please login to Firebase first:"
    echo "firebase login"
    exit 1
fi

# Deploy the rules
echo "Deploying rules to Firestore..."
firebase deploy --only firestore:rules

echo "Firestore rules deployed successfully!"
echo ""
echo "You can also deploy rules manually by:"
echo "1. Go to Firebase Console > Firestore Database > Rules"
echo "2. Copy the content from firebase/firestore.rules"
echo "3. Paste it in the rules editor"
echo "4. Click 'Publish'"
