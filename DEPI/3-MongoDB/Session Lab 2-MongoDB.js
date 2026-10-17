db.createCollection("students", {
    validator: {
        $jsonSchema: {
            bsonType: "object",
            required: ["name", "age", "major"],
            properties: {
                name: {
                    bsonType: "string",
                    description: "Name must be a string and is required"
                },
                age: {
                    bsonType: "int",
                    minimum: 18,
                    maximum: 60,
                    description: "Age must be an integer between 18 and 60"
                },
                major: {
                    bsonType: "string",
                    enum: ["IS", "AI", "CS"],
                    description: "Major must be IS, AI, or CS"
                },
                gpa: {
                    bsonType: ["double", "int"],
                    minimum: 0,
                    maximum: 4
                }
            }
        }
    },
    validationLevel: "strict",
    validationAction: "error"
})

// collection info
db.getCollectionInfos({ name: "students" })

// ************************** Aggregations **************************

//----------employees Collection
//1.employess Total Salary for "Sales" Department 
db.employees2.find({})
//Match :filter Dep : Sales
//Group : Sum Salary
db.employees2.aggregate( [ { $match: { department:"Sales" } },{$group:{_id:"$department",totalSal:{$sum:"$salary"}}} ] )



//2.Avg Salaries for "each Department" "sorted Desc"
//Group
//Sort
db.employees2.aggregate([{
    $group:{
        _id:"$department",
        avgSal:{$avg:"$salary"}
    }
},
{
    $sort:{
        avgSal:1
    }
}])

//orders collection
db.orders.find({})
//3.total Qty Pizza order for "medium" Pizza with "Desc order" 
//match medium
//group : sum
//sort qty
db.orders.aggregate(

    // Pipeline
    [
        // Stage 1
        {
            $match: {
                // enter query here
                size:"medium"
            }
        },

        // Stage 2
        {
            $group: {
                _id: "$name",
                qty:{$sum:"$quantity"}
                
            }
        },

        // Stage 3
        {
            $sort: {
                //<field1>: <1|-1>,
                //<field2>: <1|-1> ...
                qty:1
            }
        }
    ],

    // Options
    {

    }

    // Created with Studio 3T, the IDE for MongoDB - https://studio3t.com/

);
//4.Calculate Avg Pizza order for "medium" within dates 
//From 2020 to 2022
//grouped dy "date" ,"Sorted by Date Desc" 
// and insert result to new Collection 

//match : size , date
//group :{_id :date , avg: quantity}
// sort
// out
db.orders.aggregate([{
    $match:{
        size:"medium",
        date:{
            $gt:ISODate("2020-01-01") ,
            $lt:ISODate("2022-12-30") 
        }
    }
},
{
 $group:{
     _id:"$date",
     avgQty:{$avg:"$quantity"}
 }   
},
{
 $sort:{
     date:-1
 }   
},
{
    $out:"dataTrack"
}])

//--------------- products Collection
db.orders.find({})

//5. Total Sales Amount Per Product:
//Query: Calculate the total sales amount for each product.
// Total Sales = Sum of quantity * price
db.orders.aggregate([{
    $group:{
        _id:"$name",
        totalSales :{$sum:{$multiply:["$quantity","$price"]}}
    }
}])
db.orders.find({})

//6. max "Quantity" Sold Per "Month":
//Query: get the max quantity sold per month for all products.
//into new collection named "totalSales
db.orders.aggregate([
    {
        $group: {
       _id:{$month:"$date"},
        maxSales:{$max:"$quantity"} 
        }
    }
])


//7. Yearly Sales Trends:
//Query: Get the "Laptop" total sales amount for "each year"
// over a given time period from 2020 to 2024
db.orders.aggregate([
    {
        $match: {
             name:"Cheese",           
            date: {
                $gte: ISODate("2020-01-01"),
                $lte: ISODate("2023-12-31")
            }
        }
    },
    {
        $group: {
       _id:{$year:"$date"},
       totalAmount: { $sum: { $multiply: ["$quantity", "$price"] } }
        }
    }
])

db.orders.find({})

//8. Top 1 Customer by Total Spending:
//Query: Find the top 1 customers who spent the most.
db.orders.aggregate([{
    $group:{
        _id:"$name",
        totalSales:{$sum:{$multiply:["$quantity","$price"]}}
    }
},
{
    $sort:{
     totalSales:-1  
    }
},
{
    $limit:1
}

])

// ************************** LookUps **************************

db.posts.aggregate([
  {
    $lookup: {
      from: "users", // The collection to join with
      localField: "user", // The field from the posts collection
      foreignField: "_id", // The field from the users collection
      as: "userInfo" // The alias for the joined data
    }
  },
  {
    $unwind: "$userInfo" // Unwind the array created by the $lookup stage
  },
  {
    $project: {
      title: 1,
      userName: "$userInfo.name" ,
      userEmail: "$userInfo.email",
      userId:"$userInfo._id"
    }
  }
])

db.likes.aggregate([
    {
        $lookup: {
            from: "users",
            localField: "user",
            foreignField: "_id",
            as: "userInfo"
        }
    },
    {
        $project: {
            _id: 1,
            title: 1,
            userInfo: 1
        }
    }
])

db.likes.aggregate([
    {
        $lookup: {
            from: "users",
            localField: "user",
            foreignField: "_id",
            as: "userInfo"
        }
    },
    {
    $unwind: "$userInfo"
    },
    {
        $project: {
            _id: 1,
            title: 1,
            userInfo: 1
        }
    }
])


db.posts.aggregate([
  {
    $lookup: {
      from: "users", 
      localField: "user", 
      foreignField: "_id", 
      as: "userInfo" 
    }
  },
  {
    $unwind: "$userInfo" 
  },
  {
    $project: {
      title: 1,
      userName: "$userInfo.name" ,
      userEmail: "$userInfo.email",
      userAge:"$userInfo.age",
      userId:"$userInfo._id"
    }
  },
  {
    $out:'testtest10'
  }
])


db.department.find({})

  db.emp.find({})

db.department_emp_view.find({})

db.createView("dep_emp_view", "department", [
    {
        $lookup: {
            from: "emp",
            localField: "_id",
            foreignField: "dep_id",
            as: "employees"
        }
    },
    {
        $project: {
            _id: 1,
            name: 1,
            code: 1,
            employees: {
                $map: {
                    input: "$employees",
                    as: "employee",
                    in: {
                        _id: "$$employee._id",
                        name: "$$employee.name"
                    }
                }
            }
        }
    }
])

// ************************** Docker **************************

// connect to MongoDB via Docker
docker exec -it mongodb mongosh --username admin --password "Mongo123!" --authenticationDatabase admin

// we must exit from mongosh
// backup
// if not docker
mongodump --db DEPI --out E:/DEPI/04_MongoDB/Day2
//if docker
docker exec mongodb mongodump --db DEPI --username admin --password "Mongo123!" --authenticationDatabase admin --out /backup

docker cp mongodb:/backup/DEPI "E:/DEPI/04_MongoDB/Day2/"


// import
docker cp "E:/DEPI/04_MongoDB/Day2/DEPI" mongodb:/DEPI/

// --drop if database already contains
docker exec mongodb mongorestore --db DEPI --username admin --password "Mongo123!" --authenticationDatabase admin /DEPI

// access backup and restore in docker container
docker exec -it mongodb bash

docker exec -it mongodb sh