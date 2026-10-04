//Setup and sample data
use demo2DB;

db.employees2.insertMany([
{ _id: 1, name: "Mona", department: "Sales", salary: 12000 },
{ _id: 2, name: "Omar", department: "Sales", salary: 15000 },
{ _id: 3, name: "Nour", department: "Sales", salary: 18000 },
{ _id: 4, name: "Salma", department: "IT", salary: 20000 },
{ _id: 5, name: "Youssef", department: "IT", salary: 24000 },
{ _id: 6, name: "Hana", department: "HR", salary: 14000 },
{ _id: 7, name: "Ali", department: "HR", salary: 16000 },
{ _id: 8, name: "Rana", department: "IT", salary: 22000 }]);

db.orders.insertMany([
{ _id: 1, name: "Cheese", size: "medium", quantity: 2, price: 100, customer: "Mona", date:
ISODate("2020-06-15T12:00:00Z") },
{ _id: 2, name: "Pepperoni", size: "medium", quantity: 3, price: 140, customer: "Omar", date:
ISODate("2020-06-15T12:00:00Z") },
{ _id: 3, name: "Cheese", size: "large", quantity: 4, price: 150, customer: "Mona", date:
ISODate("2020-07-10T12:00:00Z") },
{ _id: 4, name: "Veggie", size: "medium", quantity: 1, price: 110, customer: "Lina", date:
ISODate("2021-03-12T12:00:00Z") },
{ _id: 5, name: "Cheese", size: "medium", quantity: 5, price: 100, customer: "Omar", date:
ISODate("2021-03-12T12:00:00Z") },
{ _id: 6, name: "Pepperoni", size: "small", quantity: 2, price: 90, customer: "Lina", date:
ISODate("2021-11-08T12:00:00Z") },
{ _id: 7, name: "Veggie", size: "medium", quantity: 4, price: 110, customer: "Mona", date:
ISODate("2022-02-20T12:00:00Z") },
{ _id: 8, name: "Cheese", size: "medium", quantity: 3, price: 100, customer: "Lina", date:
ISODate("2022-02-20T12:00:00Z") },
{ _id: 9, name: "Pepperoni", size: "large", quantity: 2, price: 180, customer: "Omar", date:
ISODate("2023-05-01T12:00:00Z") },
{ _id: 10, name: "Cheese", size: "small", quantity: 1, price: 75, customer: "Mona", date:
ISODate("2023-09-10T12:00:00Z") },
{ _id: 11, name: "Veggie", size: "large", quantity: 2, price: 160, customer: "Lina", date:
ISODate("2024-01-05T12:00:00Z") },
{ _id: 12, name: "Cheese", size: "medium", quantity: 2, price: 100, customer: "Omar", date:
ISODate("2024-08-18T12:00:00Z") }]);

db.users.insertMany([
{ _id: 101, name: "Mona", email: "mona@example.com", age: 27 },
{ _id: 102, name: "Omar", email: "omar@example.com", age: 31 },
{ _id: 103, name: "Lina", email: "lina@example.com", age: 24 }]);

db.posts.insertMany([
{ _id: 201, title: "MongoDB basics", user: 101 },
{ _id: 202, title: "Aggregation tips", user: 102 },
{ _id: 203, title: "Views in practice", user: 103 }]);

db.likes.insertMany([
{ _id: 301, postId: 201, user: 102 },
{ _id: 302, postId: 201, user: 103 },
{ _id: 303, postId: 202, user: 101 },
{ _id: 304, postId: 203, user: 101 }]);

db.department.insertMany([
{ _id: 1, name: "Sales", code: "SAL" },
{ _id: 2, name: "IT", code: "IT" },
{ _id: 3, name: "HR", code: "HR" },
{ _id: 4, name: "Finance", code: "FIN" }]);

db.emp.insertMany([
{ _id: 11, name: "Mona", dep_id: 1 },
{ _id: 12, name: "Omar", dep_id: 1 },
{ _id: 13, name: "Salma", dep_id: 2 },
{ _id: 14, name: "Hana", dep_id: 3 }]);

//Tasks
//A Validation
//1. Create a students collection with a $jsonSchema validator. Require name (string), age (BSON int, 18-60 inclusive), and major (one of IS, AI, CS).
//   Optional gpa must be BSON int or double, between 0 and 4 inclusive. Set validationLevel: "strict" and validationAction: "error".
db.createCollection("students", {
    validator: {
    $jsonSchema: {
        bsonType: "object",
        required: ["name", "age", "major"],
        properties: {
        name:  { bsonType: "string" },
        age:   { bsonType: "int", minimum: 18, maximum: 60 },
        major: { bsonType: "string", enum: ["IS", "AI", "CS"] },
        gpa:   { bsonType: ["int", "double"], minimum: 0, maximum: 4 }}}},
    validationLevel: "strict",
    validationAction: "error"});

//2. Insert two valid students. Use Int32(...) for age, and include a valid GPA for one student.
db.students.insertMany([
    { name: "Mona", age: Int32(22), major: "CS", gpa: 3.5 },
    { name: "Omar", age: Int32(25), major: "AI" }]);

// 3. Three invalid inserts, each in its own try/catch so the others still run
try {
  db.students.insertOne({ name: "Young", age: Int32(16), major: "CS" });      // underage
} catch (e) {
    print("Underage error: " + e.message);}

try {
  db.students.insertOne({ name: "Lina", age: Int32(23), major: "Math" });     // invalid major
} catch (e) {
    print("Invalid major error: " + e.message);}

try {
  db.students.insertOne({ name: "Hana", age: Int32(24), major: "IS", gpa: 4.5 }); // GPA > 4
} catch (e) {
    print("GPA error: " + e.message);}

// 4. Show validator and count accepted documents
db.getCollectionInfos({ name: "students" });
db.students.countDocuments();   // 2

// B. Aggregation
// 5. Total salary of Sales
db.employees2.aggregate([
    { $match: { department: "Sales" } },
    { $group: { _id: "$department", totalSalary: { $sum: "$salary" } } }]);

// 6. Average salary by department, highest to lowest
db.employees2.aggregate([
    { $group: { _id: "$department", avgSalary: { $avg: "$salary" } } },
    { $sort: { avgSalary: -1, _id: 1 } }]);

// 7. Medium orders: total quantity by pizza name, descending
db.orders.aggregate([
    { $match: { size: "medium" } },
    { $group: { _id: "$name", totalQuantity: { $sum: "$quantity" } } },
    { $sort: { totalQuantity: -1 } }]);

// 8. Medium orders, 2020-01-01 (inclusive) to 2023-01-01 (exclusive):
//    average quantity per exact date, sorted by date descending, saved with $out
db.orders.aggregate([
    { $match: {
        size: "medium",
        date: { $gte: ISODate("2020-01-01T00:00:00Z"), $lt: ISODate("2023-01-01T00:00:00Z") }
    } },
    { $group: { _id: "$date", avgQuantity: { $avg: "$quantity" } } },
    { $sort: { _id: -1 } },
    { $out: "dateTrack" }]);

db.dateTrack.find().sort({ _id: -1 });

// 9. Total revenue (quantity x price) by pizza name, highest first
db.orders.aggregate([
    { $group: { _id: "$name", totalRevenue: { $sum: { $multiply: ["$quantity", "$price"] } } } },
    { $sort: { totalRevenue: -1 } }]);

// 10. Max quantity per year and month, chronological
db.orders.aggregate([
    { $group: {
        _id: { year: { $year: "$date" }, month: { $month: "$date" } },
        maxQuantity: { $max: "$quantity" }
    } },
    { $sort: { "_id.year": 1, "_id.month": 1 } }]);

// 11. Cheese revenue per year, 2020 through 2024 inclusive
db.orders.aggregate([
    { $match: {
        name: "Cheese",
        date: { $gte: ISODate("2020-01-01T00:00:00Z"), $lt: ISODate("2025-01-01T00:00:00Z") }
    } },
    { $group: {
        _id: { $year: "$date" },
        cheeseRevenue: { $sum: { $multiply: ["$quantity", "$price"] } }
    } },
    { $sort: { _id: 1 } }]);

// 12. Customer with the highest total spending
db.orders.aggregate([
    { $group: { _id: "$customer", totalSpending: { $sum: { $multiply: ["$quantity", "$price"] } } } },
    { $sort: { totalSpending: -1 } },
    { $limit: 1 }]);


// C. Joins and output
// 13. posts -> users (posts.user = users._id)
db.posts.aggregate([
    { $lookup: { from: "users", localField: "user", foreignField: "_id", as: "authorInfo" } },
    { $unwind: "$authorInfo" },
    { $project: {
        _id: 0,
        title: 1,
        authorName: "$authorInfo.name",
        email: "$authorInfo.email",
        userId: "$authorInfo._id"} }]);

// 14. likes -> users (likes.user = users._id)
// 14a. Joined userInfo array
db.likes.aggregate([
    { $lookup: { from: "users", localField: "user", foreignField: "_id", as: "userInfo" } }]);

// 14b. One user object per like
db.likes.aggregate([
    { $lookup: { from: "users", localField: "user", foreignField: "_id", as: "userInfo" } },
    { $unwind: "$userInfo" }]);
// Explanation: $unwind turned the userInfo array (one element) into a single embedded
// object, so each like now has userInfo as an object instead of a one-item array.
// (If the array had several elements, it would output one document per element;
// if it were empty, the like would be dropped.)

// 15. Save task 13 output into postAuthorReport with $out, then query and count
db.posts.aggregate([
    { $lookup: { from: "users", localField: "user", foreignField: "_id", as: "authorInfo" } },
    { $unwind: "$authorInfo" },
    { $project: {
        _id: 0,
        title: 1,
        authorName: "$authorInfo.name",
        email: "$authorInfo.email",
        userId: "$authorInfo._id"
    } },
    { $out: "postAuthorReport" }]);

db.postAuthorReport.find();
db.postAuthorReport.countDocuments();   // 3

// 16. Rerunning a pipeline with $out replaces the entire contents of postAuthorReport
//     with the new results (the old documents are overwritten, not appended to).


// D. View
// 17. department_emp_view
db.createView("department_emp_view", "department", [
    { $lookup: { from: "emp", localField: "_id", foreignField: "dep_id", as: "employees" } },
    { $project: {
        _id: 1,
        name: 1,
        code: 1,
        employees: {
        $map: {
            input: "$employees",
            as: "e",
            in: { _id: "$$e._id", name: "$$e.name" }}}} }]);

// 18. Query the view; Finance should show employees: []
db.department_emp_view.find();
db.department_emp_view.find({ name: "Finance" });

// E. Backup and restore (PowerShell / terminal, NOT in mongosh)
// 19. Backup demo2DB (Docker, container named "mongodb"; password omitted)
//     docker exec -it mongodb mongodump -u admin --authenticationDatabase admin -p "<PASSWORD>" --db demo2DB --out /tmp/backup
//
//     Without Docker:
//     mongodump --db demo2DB --out ./backup

// 20. Restore into demo2DB_restored (never over demo2DB)
//     docker exec -it mongodb mongorestore -u admin --authenticationDatabase admin -p "<PASSWORD>" --nsInclude "demo2DB.*" --nsFrom "demo2DB.*" --nsTo "demo2DB_restored.*" /tmp/backup
//
//     Without Docker:
//     mongorestore --nsInclude "demo2DB.*" --nsFrom "demo2DB.*" --nsTo "demo2DB_restored.*" ./backup

// Verify counts in the restored database (back in mongosh)
use demo2DB_restored;
db.orders.countDocuments();   // 12
db.users.countDocuments();    // 3