using System;
using System.Collections.Generic;
using System.Linq;
using System.Data.Common;
using MySql.Data.MySqlClient;

/* 9 Download and install MySQL database, 
MySQL Connector/Net (.NET Data Provider 
for MySQL) + MySQL Workbench GUI 
administration tool . Create a MySQL 
database to store Books (title, author, 
publish date and ISBN). Write methods 
for listing all books, finding a book by 
name and adding a book.  */

static class Program
{
    static void Main(string[] args)
    {
        // http://www.connectionstrings.com/mysql-connector-net-mysqlconnection/
        // see http://dev.mysql.com/doc/refman/5.1/en/adding-users.html for instructions
        // on creating new users

        using (var conn = new MySqlConnection(
    @"Server=localhost;Database=Test;Uid=user;Pwd=123"))
        {
            conn.Open();

            var create = new MySqlCommand(
@"CREATE TABLE Books
(
    BookId INT AUTO_INCREMENT PRIMARY KEY,
    Title NVARCHAR(64),
    Author NVARCHAR(64),
    PublishDate DATE,
    ISBN CHAR(13)
)",
conn);

            // create.ExecuteNonQuery();

            //conn.AddBook("Lord of the Flies", "William Golding", DateTime.Today.AddYears(-60), "0123456789123");
            //conn.AddBook("Of Mice and Men", "John Steinbeck", DateTime.Today.AddYears(-80), "1234567891234");
            ///conn.AddBook("Art Of War", "Sun Tzu", DateTime.Today.AddYears(-1500), "2345678912345");
            //conn.AddBook("East of Eden", "John Steinbeck", DateTime.Today.AddYears(-80), "3456789123456");

            Console.WriteLine("All books:");
            Console.WriteLine();
            conn.ListAllBooks();
            Console.WriteLine();

            Console.WriteLine("By Steinbeck:");
            Console.WriteLine();
            conn.ListBooksByAuthor("John Steinbeck");
            Console.WriteLine();

        }
    }

    static void ListAllBooks(this DbConnection conn)
    {
        var command = conn.CreateCommand();
        command.CommandText = "SELECT * FROM Books";

        using (var reader = command.ExecuteReader())
        {
            while (reader.Read())
            {
                Console.WriteLine("{0}", reader.ShowReaderRow());
            }
        }
    }

    static string ShowReaderRow(this DbDataReader reader)
    {
        var array = new object[reader.FieldCount];
        reader.GetValues(array);
        return string.Join(", ", array);
    }

    static void ListBooksByAuthor(this DbConnection conn, string author)
    {
        var command = conn.CreateCommand();
        command.CommandText = "SELECT * FROM Books WHERE Author = @Author";
        command.Parameters.Add(new MySqlParameter("@Author", author));

        using (var reader = command.ExecuteReader())
        {
            while (reader.Read())
            {
                Console.WriteLine("{0}", reader.ShowReaderRow());
            }
        }
    }


    static void AddBook(this MySqlConnection conn, string title, string author, DateTime publishDate, string isbn)
    {
        var command = conn.CreateCommand();
        command.CommandText = "INSERT Books(Title, Author, PublishDate, ISBN) VALUES(@title, @author, @publishDate, @isbn)";
        command.Parameters.Add(new MySqlParameter("@title", title));
        command.Parameters.Add(new MySqlParameter("@author", author));
        command.Parameters.Add(new MySqlParameter("@publishDate", publishDate));
        command.Parameters.Add(new MySqlParameter("@isbn", isbn));

        command.ExecuteNonQuery();
    }
}
