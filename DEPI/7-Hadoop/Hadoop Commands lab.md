# Hadoop HDFS Commands

* Check the instruction of a command:
```
hdfs dfs –help
```

* Display the directory information:
```
hdfs dfs -ls /<path>
hdfs dfs –ls /
```

* Login as root to obtain all previliges
```
su
password
su - hdfs
```
* Hadoop HDFS mkdir Command:
```
hdfs dfs  –mkdir /<path/directory_name>
hdfs dfs –mkdir  / lab1dir
hdfs dfs  –ls  /
```

* Upload a  local file to specified  directory in HDFS:
```
hdfs dfs  -put  lab1.txt  /lab1dir
hdfs dfs –ls / lab1dir
```
or use
```
hdfs dfs -copyFromLocal <localsrc> <hdfs destination>
hdfs dfs -copyFromLocal lab1.txt  /lab1dir
```

* Download  specified  file  from  HDFS to a  local host:

Open any file in HDFS and use it. Then use the `get` command. Note that to move files to local from hdfs, you must be logged in as the current system user aka `cloudera` or `root`.
```
hdfs dfs -get /lab1dir/*txt /home/cloudera/Desktop
```

* Copy files from source to destination inside hdfs:
```
hdfs dfs -cp <Source/dir> <Destination/dir>
hdfs dfs -cp /lab1dir/lab123.txt /tmp

hdfs dfs -ls /tmp
```

*  Move files:
```
hdfs dfs -mv /<path to file name> /<dir/to move into>
hdfs dfs -mv /tmp/lab123.txt /user

hdfs dfs -ls /user
```

* Display the content of the  file:
```
hdfs dfs –cat /<path_to_file_in_hdfs>
hdfs dfs –cat /lab1dir/lab1.txt
```

* Add data to the end of a file:
```
cat appedtxt.txt
hdfs dfs –appendToFile    /<source files name> /<Hadoop file to be append>
hdfs dfs -appendToFile   appedtxt.txt   /lab1.txt  
hdfs dfs -cat  /lab1.txt
```

* Delete file or folder:
This command will temporarily move the files to trash.
```
hdfs dfs –rm  path
hdfs dfs -rm /user/lab123.txt

hdfs dfs -ls /user
```

* Check the available space of file system:
```
hdfs dfs –df  
```

* Modify the permissions:
```
hdfs dfs -ls /lab1dir
hdfs dfs -chmod 777 /lab1dir/lab1.txt
hdfs dfs -ls /lab1dir
```

Note that The `777` in the command is a *UNIX-style* permission code used to set access rights on files or directories. Each digit in `777` represents different levels of permission for different types of users.

**Understanding Permissions**

The permission string is made up of three digits, each ranging from 0 to 7:

```
[hdfs dfs -chmod] [Owner] [Group] [Others]
          ↓         ↓       ↓        ↓
        chmod      7       7        7
```

Each digit is a sum of:

| Number | Permission  | Meaning                                                      |
| ------ | ----------- | ------------------------------------------------------------ |
| 4      | Read (r)    | Can view the file contents                                   |
| 2      | Write (w)   | Can modify or delete the file                                |
| 1      | Execute (x) | Can run the file (if script or binary), or enter a directory |

So:

* `7` = `4+2+1` = **read + write + execute**
* `6` = `4+2`   = **read + write**
* `5` = `4+1`   = **read + execute**
* `0` = no permission

**Example:**

```bash
hdfs dfs -chmod 777 /lab1dir/lab1.txt
```
Means:

| User Type | Permissions            |
| --------- | ---------------------- |
| Owner     | read + write + execute |
| Group     | read + write + execute |
| Others    | read + write + execute |

So anyone can read, write, or execute the file.

## Summary Table of Common Modes

| Mode | Meaning                          | Who Can Do What                |
| ---- | -------------------------------- | ------------------------------ |
| 777  | All can read/write/execute       | Very open                      |
| 755  | Owner full, others can read/exec | Typical for scripts or folders |
| 644  | Owner read/write, others read    | Good for public text files     |
| 600  | Only owner has access            | For private files              |

