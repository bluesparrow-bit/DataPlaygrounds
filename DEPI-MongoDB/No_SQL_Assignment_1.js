//Setup and sample data

use moviesDB;

db.createCollection("movies");

db.movies.insertMany([
{ _id: 1, title: "The Last Lighthouse", genre: "Drama", year: 2018, rating: 8.2, duration: 112,
director: "Maya Hassan", actors: ["Omar Nabil", "Lina Adel"], available: true, city: "Cairo" },
{ _id: 2, title: "Code Red", genre: "Action", year: 2021, rating: 7.4, duration: 125, director:
"Adam Saleh", actors: ["Nora Ali", "Karim Fathy"], available: true, city: "Alexandria" },
{ _id: 3, title: "Beyond the Stars", genre: "Sci-Fi", year: 2023, rating: 8.7, duration: 140,
director: "Maya Hassan", actors: ["Lina Adel", "Sara Amin"], available: false, city: "Cairo" },
{ _id: 4, title: "Quiet Streets", genre: "Drama", year: 2016, rating: 6.9, duration: 98,
director: "Youssef Farid", actors: ["Omar Nabil"], available: true },
{ _id: 5, title: "The Hidden Map", genre: "Adventure", year: 2020, rating: 7.8, duration: 116,
director: "Nora Kamal", actors: ["Karim Fathy", "Sara Amin"], available: true, city: "Giza" },
{ _id: 6, title: "Midnight Signal", genre: "Thriller", year: 2022, rating: 8.1, duration: 104,
director: "Adam Saleh", actors: ["Nora Ali", "Omar Nabil"], available: false, city: "Cairo" },
{ _id: 7, title: "Paper Planets", genre: "Sci-Fi", year: 2019, rating: 7.2, duration: 108,
director: "Maya Hassan", actors: ["Sara Amin"], available: true },
{ _id: 8, title: "Summer Recipe", genre: "Comedy", year: 2024, rating: 6.8, duration: 95,
director: "Nora Kamal", actors: ["Lina Adel", "Karim Fathy"], available: true, city: "Alexandria" },
{ _id: 9, title: "The Long Journey", genre: "Adventure", year: 2017, rating: 8.0, duration: 132,
director: "Youssef Farid", actors: ["Omar Nabil", "Nora Ali"], available: false, city: "Giza"},
{ _id: 10, title: "City of Echoes", genre: "Thriller", year: 2021, rating: 7.9, duration: 118,
director: "Adam Saleh", actors: ["Sara Amin", "Lina Adel"], available: true, city: "Cairo" },
{ _id: 11, title: "Small Wonders", genre: "Comedy", year: 2015, rating: 7.1, duration: 91,
director: "Nora Kamal", actors: ["Karim Fathy"], available: false },
{ _id: 12, title: "Ocean Window", genre: "Drama", year: 2023, rating: 8.5, duration: 121,
director: "Youssef Farid", actors: ["Lina Adel", "Nora Ali"], available: true, city: "Alexandria" }
]);


//A. Explore and query
//1. Show all databases and all collections in moviesDB.

show dbs;
/*
admin     100.00 KiB
config     92.00 KiB
local      72.00 KiB
moviesDB   40.00 KiB
*/

show collections;
//movies

//2. Display all movies. Then retrieve one movie by its exact title: Code Red.

db.movies.find({});

db.movies.find({title: 'Code Red'});
/*
[
  {
    _id: 2,
    title: 'Code Red',
    genre: 'Action',
    year: 2021,
    rating: 7.4,
    duration: 125,
    director: 'Adam Saleh',
    actors: [ 'Nora Ali', 'Karim Fathy' ],
    available: true,
    city: 'Alexandria'
  }
]
*/

//3. Find movies released in or after 2021.

db.movies.find({year:{$gte:2021}});

//4. Find movies with a rating of at least 8.0 or genre Comedy.

db.movies.find({$or:[{rating:{$gte:2021}},{genre:'Comedy'}]});

//5. Find all movies featuring Lina Adel in the actors array.

db.movies.find({actors:'Lina Adel'});

//6. Find movies that contain a city field; then find movies without it.

db.movies.find({city:{$exists:true}});

db.movies.find({city:{$exists:false}});

//7. Show titles and ratings only, hiding _id, sorted by rating from highest to lowest.

db.movies.find({}, {title:1, rating:1, _id:0}).sort({rating:-1});

//8. Sort by year ascending, then title ascending. Show only the third and fourth results.

db.movies.find({}).sort({year:-1});

db.movies.find({}).sort({title:-1});

db.movies.find({}).sort({title:-1}).skip(2).limit(2);

//9. Count movies whose available value is true.

db.movies.find({available:true}).count();

//B. Insert and modify
//10. Insert one new movie of your choice with _id: 13 and the same core fields as the existing movies.

db.movies.insertOne({
                    _id:13, 
                    title: 'Summer Sadness',
                    genre: 'Drama',
                    year: 2024,
                    rating: 4.8,
                    duration: 95,
                    director: 'Nora Kamal',
                    actors: [ 'Lina Adel', 'Karim Fathy' ],
                    available: true,
                    city: 'Alexandria'});

//11. Insert two more movies with _id: 14 and _id: 15 in a single command.

db.movies.insertMany([{
                    _id:14, 
                    title: 'Summer Sadness',
                    genre: 'Drama',
                    year: 2024,
                    rating: 4.8,
                    duration: 95,
                    director: 'Nora Kamal',
                    actors: [ 'Lina Adel', 'Karim Fathy' ],
                    available: true,
                    city: 'Alexandria'},
                    {
                    _id:15, 
                    title: 'Summer Sadness',
                    genre: 'Drama',
                    year: 2024,
                    rating: 4.8,
                    duration: 95,
                    director: 'Nora Kamal',
                    actors: [ 'Lina Adel', 'Karim Fathy' ],
                    available: true,
                    city: 'Alexandria'}]);

//12. Change Code Red's rating to 7.9 using $set.

db.movies.updateOne({title:'Code Red'}, {$set:{rating:7.9}});

//13. Add 0.2 to the rating of every Comedy movie using $inc.

db.movies.updateMany({genre:'Comedy'}, {$inc:{rating:0.2}});

//14. Rename the city field to filmingCity only for The Last Lighthouse.

db.movies.updateOne({title:'The Last Lighthouse'}, {$set:{city:'filmingCity'}});

//15. Remove the duration field from Quiet Streets using $unset.

db.movies.updateOne({title:'Quiet Streets'}, {$unset:{duration:''}});

//16. Verify tasks 12-15 with find() queries.

db.movies.find({title: 'Code Red'});

db.movies.find({genre:'Comedy'});

db.movies.find({title:'The Last Lighthouse'});

db.movies.find({title:'Quiet Streets'});

//C. Delete
//17. Delete your movie with _id: 15 using deleteOne().

db.movies.deleteOne({_id:15})

//18. Delete all movies released before 2017 using deleteMany().

db.deleteMany({year:{lt:2017}})

//19. Show how many documents remain after both deletes.

db.movies.find().count()
//14

//D. Aggregation
//20. Group movies by genre and count the movies in each genre.

db.movies.aggregate([
    {$group:{_id:"$genre", count:{$sum:1}}}
])

//21. Filter to movies with a rating of at least 8.0, then group by director and count movies per director.

db.movies.aggregate([
    {$match: {rating: {$gte: 8}}},
    {$group: {_id: "$director", count:{$sum: 1}}}
])

//22. Group by genre and calculate the average rating for each genre; sort by average rating descending.

db.movies.aggregate([
    {$group: {_id: "$genre", AverageRating: {$avg: "$rating"}}},
    {$sort:{AverageRating:1}}
])

//E. Indexes and cleanup
//23. Create an ascending index on title and display all indexes.

db.movies.createIndex({title: 1})

db.movies.getIndexes()

//24. Create a compound index on genre ascending and year descending. Display all indexes again.

db.movies.createIndex({genre: 1, year: -1})

db.movies.getIndexes()

//25. Drop only the title index. Show that the compound index remains.

db.movies.dropIndex("title_1")

db.movies.getIndexes()
