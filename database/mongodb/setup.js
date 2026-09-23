// Fictional classroom data matching Oracle 05_sample_data.sql.
// In mongosh, first enter: use smartmove
// Then paste these commands. Run once: repeating inserts creates duplicates.
// Collections are created automatically when their first document is inserted.
// Oracle IDs are strings here, for example "1".

db.feedback_content.insertOne({
    "feedbackId": "1",
    "routeId": "1",
    "vehicleId": "1",
    "driverId": "1",
    "vehicleRating": 4,
    "driverRating": 5,
    "comment": "The vehicle was clean and the driver was helpful, but arrival was late.",
    "keywords": ["clean", "helpful", "late"],
    "reply": {
        "staffName": "Demo Staff",
        "message": "Thank you for your feedback."
    }
});

db.vehicle_assets.insertOne({
    "vehicleId": "1",
    "assetType": "IMAGE",
    "fileUrl": "/uploads/demo-vehicle.jpg"
});

db.announcements.insertOne({
    "title": "Arrive early",
    "body": "Please arrive 15 minutes before departure.",
    "audience": "PASSENGERS"
});

db.notifications.insertOne({
    "userId": "2",
    "message": "Your booking 2 is confirmed.",
    "isRead": false
});

db.trip_media.insertOne({
    "tripId": "1",
    "uploadedBy": "1",
    "mediaType": "IMAGE",
    "fileUrl": "/uploads/demo-trip.jpg",
    "caption": "Demo journey photo"
});

// The file URLs are placeholders. No actual images are included.
