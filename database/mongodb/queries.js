// In mongosh, first enter: use smartmove
// Add setup.js sample documents before trying these queries.

// 1. Read feedback for route 1.
db.feedback_content.find({ "routeId": "1" });

// 2. Show individual reviews with vehicle ratings from highest to lowest.
db.feedback_content.find({}).sort({ "vehicleRating": -1 });

// 3. Average ratings for each vehicle. Compare the averages to find the highest.
// $group is the only aggregation stage used; results are not sorted.
db.feedback_content.aggregate([
    { $group: { _id: "$vehicleId", averageRating: { $avg: "$vehicleRating" } } }
]);

// 4. Average ratings for each driver.
db.feedback_content.aggregate([
    { $group: { _id: "$driverId", averageRating: { $avg: "$driverRating" } } }
]);

// 5. Find feedback tagged with either keyword.
// Matches stored keywords, not arbitrary words inside the comment.
db.feedback_content.find({ "keywords": { $in: ["late", "delay"] } });

// 6. View vehicle files and trip photos.
db.vehicle_assets.find({ "vehicleId": "1" });
db.trip_media.find({ "tripId": "1" });

// 7. Count feedback documents and find unread notifications.
db.feedback_content.countDocuments();
db.notifications.find({ "userId": "2", "isRead": false });

// Optional CRUD practice: copy ONE command from this comment when needed.
// These commands change data, so they are commented out.
/*
db.notifications.updateOne(
    { "userId": "2", "message": "Your booking 2 is confirmed." },
    { $set: { "isRead": true } }
);

db.announcements.deleteOne({ "title": "Arrive early" });
*/
