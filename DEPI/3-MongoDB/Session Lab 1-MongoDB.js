// MongoDB Practice

MongoDB Exercise in mongo shell

show dbs;
// Syntax
use database_name

// Example
use mongo_practice
// Syntax
db.createCollection("name_collection")

// Example
db.createCollection("users")
// Syntax
show collections
// Syntax
db.collection.insertOne({ jason_object })

// Example
db.users.insertOne({ name: "John", age: 30 })
// Syntax
db.collection.insertMany([objects_data])

// Example
db.users.insertMany([
    { name: "Sally", age: 25 },
    { name: "Mike", age: 40 }
])
// Syntax
db.collection.find()

// Example
db.users.find()
// Syntax
db.collection.findOne({ data_example })

// Example
db.users.findOne({ name: "John" })
// Syntax
db.collection.find({ property: { $gte: val } })

// Example
db.users.find({ age: { $gte: 30 } })

db.users.find({ $or: [{ name: "John" }, { age: { $lte: 25 } }] })
// Syntax
db.collection.updateOne({ name: val }, { $set: { updated_val } })

// Example
db.users.updateOne({ name: "John" }, { $set: { age: 35 } })

db.users.find({ name: "John" })
// Syntax
db.collection.updateMany({}, { $inc: { val } })

// Example
db.users.updateMany({}, { $inc: { age: 1 } })

db.users.find()
// Syntax
db.users.updateOne({ name: "John" }, { $rename: { "name": "full_name" } })

// Example
db.users.updateOne({ name: "John" }, { $rename: { "name": "full_name" } })
db.users.find({ full_name: "John" })
db.users.updateOne({ full_name: "John" }, { $unset: { age: "" } })
db.users.find({ full_name: "John" })
// Syntax
db.users.deleteOne({ full_name: "John" })

// Example
db.users.deleteOne({ full_name: "John" })
db.users.find()
// Syntax
db.users.deleteMany({ age: { $lt: 30 } })

// Example
db.users.deleteMany({ age: { $lt: 30 } })
db.users.find()
db.users.insertMany([
    { name: "Sally", age: 19 },
    { name: "Han Yeori", age: 24 },
    { name: "Mary", age: 27 },
    { name: "Charlotte", age: 38 },
    { name: "Elizabeth", age: 27 },
    { name: "Kate", age: 26 },
    { name: "Sam", age: 27 },
    { name: "Goerge", age: 19 },
    { name: "Tony", age: 32 },
])
db.users.find().sort({ age: 1 })
db.users.find({ address: { $exists: true } })
db.users.find().limit(2)
db.users.find().skip(1).limit(2)
// Count users by age
db.users.aggregate([
    { $group: { _id: "$age", count: { $sum: 1 } } }
])
// Step 1. Filter users with age >= 30
// Step 2. Count by name
db.users.aggregate([
    { $match: { age: { $gte: 30 } } },
    { $group: { _id: "$name", total: { $sum: 1 } } }
])
// Syntax
db.users.createIndex({ name: 1 })

// Example
db.users.createIndex({ name: 1 })
db.users.getIndexes()
// Syntax
db.collection.dropIndex("name_index")

// Example
db.users.dropIndex("name_1")
// Multiple Column Indexes
db.users.createIndex({ city: 1, age: 1 })
db.users.getIndexes()
// Syntax
db.collection_name.drop()

// Example
db.users.drop()
show collections
// Syntax
db.dropDatabase("db_name)

// Example
db.dropDatabase("mongo_practice")
show dbs
exit
// Movies Database Usecase Scenario
// Create Database
Connect to a running mongo instance, use a database named`movie_db`
use movie_db
// Insert Documents

Insert the following documents into a`movies` collection.

```
title : Fight Club
writer : Chuck Palahniuk
year : 1999
actors : [
    Brad Pitt
    Edward Norton
]
```

    ```
title : Pulp Fiction
writer : Quentin Tarantino
year : 1994
actors : [
    John Travolta
    Uma Thurman
]
```

    ```
title : Inglorious Basterds
writer : Quentin Tarantino
year : 2009
actors : [
    Brad Pitt
    Diane Kruger
    Eli Roth
]
```

    ```
title : The Hobbit: An Unexpected Journey
writer : J.R.R. Tolkein
year : 2012
franchise : The Hobbit
```

    ```
title : The Hobbit: The Desolation of Smaug
writer : J.R.R. Tolkein
year : 2013
franchise : The Hobbit
```

    ```
title : The Hobbit: The Battle of the Five Armies
writer : J.R.R. Tolkein
year : 2012
franchise : The Hobbit
synopsis : Bilbo and Company are forced to engage in a war against an array of combatants and keep the Lonely Mountain from falling into the hands of a rising darkness.
```

    ```
title : Pee Wee Herman's Big Adventure
```

    ```
title : Avatar
```

db.createCollection("movies")

// documents
info = [
        {
            "title": "Fight Club", "writer": "Chuck Palahniuk",
            "year": 1999,
            "actors": ["Brad Pitt", "Edward Norton"]
        },
        {
            "title": "Pulp Fiction",
            "writer": "Quentin Tarantino",
            "year": 1994,
            "actors": ["John Travolta", "Uma Thurman"]
        },
        {
            "title": "Inglorious Basterds",
            "writer": "Quentin Tarantino",
            "year": 2009,
            "actors": ["Brad Pitt", "Diane Kruger", "Eli Roth"]
        },
        {
            "title": "The Hobbit: The Desolation of Smaug",
            "writer": "J.R.R. Tolkein",
            "year": 2013,
            "franchise": "The Hobbit"
        },
        {
            "title": "The Hobbit: An Unexpected Journey",
            "writer": "J.R.R. Tolkein",
            "year": 2012,
            "franchise": "The Hobbit"
        },
        {
            "title": "The Hobbit: The Battle of the Five Armies",
            "writer": "J.R.R. Tolkein",
            "year": 2012,
            "franchise": "The Hobbit",
            "synopsis": "Bilbo and Company are forced to engage in a war against an array of combatants and keep the Lonely Mountain from falling into the hands of a rising darkness."
        },
        {
            "title": "Pee Wee Herman's Big Adventure"
        },
        {
            "title": "Avatar"
        }
    ]


// inserting documents
db.movies.insertMany(info)
// Query / Find Documents

query the`movies` collection to

1. get all documents
db.movies.find()

2. get all documents with `writer` set to "Quentin Tarantino"
db.movies.find({ writer: "Quentin Tarantino" })
3. get all documents where `actors` include "Brad Pitt"
db.movies.find({ actors: "Brad Pitt" })
4. get all documents with `franchise` set to "The Hobbit"
db.movies.find({ franchise: "The Hobbit" })
5. get all movies released in the 90s
db.movies.find({ year: { $gte: 1990, $lte: 2000 } })
6. get all movies released before the year 2000 or after 2010
db.movies.find({ $or: [{ year: { $gt: 2010 } }, { year: { $lt: 2000 } }] })
// Update Documents

1. Add a synopsis to:
```
    "The Hobbit: An Unexpected Journey": 
        "A reluctant hobbit, Bilbo Baggins, sets out to the Lonely Mountain with a spirited group of dwarves to reclaim their mountain home - and the gold within it - from the dragon Smaug."
    ```
db.movies.update({ "title": "The Hobbit: An Unexpected Journey" }, { $set: { synopsis: "A reluctant hobbit, Bilbo Baggins, sets out to the Lonely Mountain with a spirited group of dwarves to reclaim their mountain home - and the gold within it - from the dragon Smaug." } })
2. Add a synopsis to:
```
    "The Hobbit: The Desolation of Smaug": 
        "The dwarves, along with Bilbo Baggins and Gandalf the Grey, continue their quest to reclaim Erebor, their homeland, from Smaug. Bilbo Baggins is in possession of a mysterious and magical ring."
```
db.movies.updateOne({ "title": "The Hobbit: The Desolation of Smaug" }, { $set: { synopsis: "The dwarves, along with Bilbo Baggins and Gandalf the Grey, continue their quest to reclaim Erebor, their homeland, from Smaug. Bilbo Baggins is in possession of a mysterious and magical ring." } })
db.movies.find({ "title": "The Hobbit: The Desolation of Smaug" })
3. Add an actor named: `"Samuel L. Jackson"` to the movie`"Pulp Fiction"`.
    db.movies.updateOne({ "title": "Pulp Fiction" }, { $push: { actors: "Samuel L. Jackson" } })
db.movies.find({ "title": "Pulp Fiction" })
// Text Search

1. Find all movies that have a synopsis that contains the word`"Bilbo"`.
    db.movies.find({ synopsis: { $regex: "Bilbo" } })
2. Find all movies that have a synopsis that contains the word`"Gandalf"`.
    db.movies.find({ synopsis: { $regex: "Gandalf" } })
3. Find all movies that have a synopsis that contains the word `"Bilbo"` and not the word`"Gandalf"`.
    db.movies.find({ $and: [{ synopsis: { $regex: "Bilbo" } }, { synopsis: { $not: /Gandalf/ } }] })
4. Find all movies that have a synopsis that contains the word `"dwarves"` or`"hobbit"`.
    db.movies.find({ $or: [{ synopsis: { $regex: "dwarves" } }, { synopsis: { $regex: "hobbit" } }] })
5. Find all movies that have a synopsis that contains the word `"gold"` and`"dragon"`.
    db.movies.find({ $and: [{ synopsis: { $regex: "gold" } }, { synopsis: { $regex: "dragon" } }] })
// Delete Documents

1. Delete the movie`"Pee Wee Herman's Big Adventure"`.
    db.movies.deleteOne({ "title": "Pee Wee Herman's Big Adventure" })
db.movies.find({ "title": "Pee Wee Herman's Big Adventure" })
2. Delete the movie`"Avatar"`.
    db.movies.deleteOne({ "title": "Avatar" })
db.movies.find({ "title": "Avatar" })
    // Relationships
    //// Insert the following documents into a `users` collection:

    ```
username : GoodGuyGreg
first_name : "Good Guy"
last_name : "Greg"
```

    ```
username : ScumbagSteve
full_name :
  first : "Scumbag"
  last : "Steve"

```
db.createCollection("users")
db.users.insertOne({ _id: 1, username: "GoodGuyGreg", first_name: "Good Guy", last_name: "Greg" })
db.users.insertOne({ _id: 2, username: "ScumbagSteve", fullname: { first: "Scumbag", last: "Steve" } })
    //// Insert the following documents into a `posts` collection:

    ```
username : GoodGuyGreg
title : Passes out at party
body : Wakes up early and cleans house
```
db.posts.insertOne({ username: "GoodGuyGreg", title: "Passes out at Party", body: "Raises your credit score" })
    ```
username : GoodGuyGreg
title : Steals your identity
body : Raises your credit score
```
db.posts.insertOne({ username: "GoodGuyGreg", title: "Steals your identity", body: "Raises your credit score" })
    ```
username : GoodGuyGreg
title : Reports a bug in your code
body : Sends you a Pull Request
```
db.posts.insertOne({ username: "GoodGuyGreg", title: "Reports a bug in your code", body: "Sends you a pull request" })
    ```
username : ScumbagSteve
title : Borrows something
body : Sells it
```
db.posts.insertOne({ username: "ScumbagSteve", title: "Borrows something", body: "Sells it" })
    ```
username : ScumbagSteve
title : Borrows everything
body : The end
```
db.posts.insertOne({ username: "ScumbagSteve", title: "Borrows everything", body: "The end" })
    ```
username : ScumbagSteve
title : Forks your repo on github
body : Sets to private
```
db.posts.insertOne({ username: "ScumbagSteve", title: "Forks your repo on github", body: "Sets to private" })
    //// Insert the following documents into a `comments` collection

    ```
username : GoodGuyGreg
comment : Hope you got a good deal!
post : post_obj_id
```
where `post_obj_id` is the ObjectId of the `posts` document: "Borrows something"

db.createCollection("comments")
db.comments.insert({
    username: "GoodGuyGreg",
    comment: "Hope you got a good deal!",
    post: db.posts.findOne({ title: "Borrows something" })._id
})
    ```
username : GoodGuyGreg
comment : What's mine is yours!
post : post_obj_id
```
where `post_obj_id` is the ObjectId of the `posts` document: "Borrows everything"

db.comments.insert({
    username: "GoodGuyGreg",
    comment: "What's mine is yours!",
    post: db.posts.findOne({ title: "Borrows everything" })._id
})
    ```
username : GoodGuyGreg
comment : Don't violate the licensing agreement!
post : post_obj_id
```
where `post_obj_id` is the ObjectId of the `posts` document: "Forks your repo on github"

db.comments.insert({
    username: "GoodGuyGreg",
    comment: "Don't violate the licensing agreement!",
    post: db.posts.findOne({ title: "Forks your repo on github" })._id
})
    ```
username : ScumbagSteve
comment : It still isn't clean
post : post_obj_id
```
where `post_obj_id` is the ObjectId of the `posts` document: "Passes out at party"
db.comments.insert({
    username: "ScumbagSteve",
    comment: "It still isn't clean",
    post: db.posts.findOne({ title: "Passes out at Party" })._id
})
    ```
username : ScumbagSteve
comment : Denied your PR cause I found a hack
post : post_obj_id
```
where `post_obj_id` is the ObjectId of the `posts` document: "Reports a bug in your code"
db.comments.insert({
    username: "ScumbagSteve",
    comment: "Denied your PR cause I found a hack",
    post: db.posts.findOne({ title: "Reports a bug in your code" })._id
})
// Querying related collections

1. Find all users.
    db.users.find().pretty()
2. Find all posts.
    db.posts.find().pretty()
3. Find all posts that was authored by`"GoodGuyGreg"`.
    db.posts.find({ username: "GoodGuyGreg" })
4. Find all posts that was authored by`"ScumbagSteve"`.
    db.posts.find({ username: "ScumbagSteve" })
5. Find all comments.
    db.comments.find().pretty()
6. Find all comments that was authored by`"GoodGuyGreg"`.
    db.comments.find({ username: "GoodGuyGreg" })
7. Find all comments that was authored by`"ScumbagSteve"`.
    db.comments.find({ username: "ScumbagSteve" })
    // Import a csv to mongodb


    ``` 
{ "_id" : "02906", "city" : "PROVIDENCE", "pop" : 31069, "state" : "RI", "capital" : { "name" : "Providence", "electoralCollege" : 4 } }
{ "_id" : "02108", "city" : "BOSTON", "pop" : 3697, "state" : "MA", "capital" : { "name" : "Boston", "electoralCollege" : 11 } }
{ "_id" : "10001", "city" : "NEW YORK", "pop" : 18913, "state" : "NY", "capital" : { "name" : "Albany", "electoralCollege" : 29 } }
{ "_id" : "01012", "city" : "CHESTERFIELD", "pop" : 177, "state" : "MA", "capital" : { "name" : "Boston", "electoralCollege" : 11 } }
{ "_id" : "32801", "city" : "ORLANDO", "pop" : 9275, "state" : "FL", "capital" : { "name" : "Tallahassee", "electoralCollege" : 29 } }
{ "_id" : "12966", "city" : "BANGOR", "pop" : 2867, "state" : "NY", "capital" : { "name" : "Albany", "electoralCollege" : 29 } }
{ "_id" : "32920", "city" : "CAPE CANAVERAL", "pop" : 7655, "state" : "FL", "capital" : { "name" : "Tallahassee", "electoralCollege" : 29 } }
{ "_id" : "NY", "name" : "New York", "pop" : 28300000, "state" : 1788 }
{ "_id" : "33125", "city" : "MIAMI", "pop" : 47761, "state" : "FL", "capital" : { "name" : "Tallahassee", "electoralCollege" : 29 } }
{ "_id" : "RI", "name" : "Rhode Island", "pop" : 1060000, "state" : 1790 }
{ "_id" : "MA", "name" : "Massachusetts", "pop" : 6868000, "state" : 1790 }
{ "_id" : "FL", "name" : "Florida", "pop" : 6800000, "state" : 1845 }
{ "_id" : "1", "name" : "Tom", "addresses" : [ "01001", "12997" ] }
{ "_id" : "02907", "city" : "CRANSTON", "pop" : 25668, "state" : "RI", "capital" : { "name" : "Providence", "electoralCollege" : 4 } }
{ "_id" : "2", "name" : "Bill", "addresses" : [ "01001", "12967", "32920" ] }
{ "_id" : "3", "name" : "Mary", "addresses" : [ "32801", "32920", "33125" ] }
{ "_id" : "12967", "city" : "NORTH LAWRENCE", "pop" : 943, "state" : "NY", "capital" : { "name" : "Albany", "electoralCollege" : 29 } }
{ "_id" : "01001", "city" : "AGAWAM", "pop" : 15338, "state" : "MA", "capital" : { "name" : "Boston", "electoralCollege" : 11 } }
{ "_id" : "12997", "city" : "WILMINGTON", "pop" : 958, "state" : "NY", "capital" : { "name" : "Albany", "electoralCollege" : 29 } }
```

mongoimport--db < database_name > --collection < collection_name > --file < drag file here >
    mongoimport--db movie_db--collection docs--file cities.csv
1. Show name and population of the cities where the population is over 10000
db.docs.find({ city: { $exists: true } }, { _id: 0, city: 1, pop: 1 }, { pop: { $gt: 10000 } })
2. Show the name and population of the state based on the cities shown.
    db.docs.aggregate([{ $match: { city: { $exists: true } } }, { $group: { _id: "$state", "Total Pop": { $sum: "$pop" } } }])
3. Show the total cities in NY as 'Population'.
db.docs.aggregate([{ $match: { state: "NY" } }, { $group: { _id: "$state", "Total Pop": { $sum: "$pop" } } }])
4. Show the _id, city, name of the capital city of each state with a popultaion greater than 20,000.
    db.docs.find({ city: { $exists: true }, pop: { $gt: 20000 } }, { city: 1, "capital.name": 1 })