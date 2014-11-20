#!/usr/bin/env python
"""database_anonymizer.py: Class file for removing sensitive from a MySQL database"""
import MySQLdb
import sys


class DatabaseAnonymizer:

    def __init__(self, host="localhost", user="MyUser", password="MyPassword", database="MyDatabase",
                 email_user='admin', email_host='example.com'):
        self.host = host
        self.user = user
        self.password = password
        self.database = database
        self.email_user = email_user
        self.email_host = email_host
        self.debug = 1
        self.create_connection()

    def create_connection(self):
        try:
            self.connection = MySQLdb.connect(self.host, self.user, self.password, self.database)
            if self.debug:
                print "Connected to %s as %s/%s" % (self.database, self.user, self.password)

        except MySQLdb.Error, e:
            print "Error: unable to connect to database"
            print "Error %d: %s" % (e.args[0], e.args[1])
            sys.exit(1)

    def execute(self, sql_statement):
        try:
            cursor = self.connection.cursor()
            cursor.execute(sql_statement)
            result = cursor.fetchall()
            cursor.close()
            return result

        except MySQLdb.Error, e:
            print "Error: unable to connect to database"
            print "Error %d: %s" % (e.args[0], e.args[1])

    def count_rows(self, table):
        cursor = self.connection.cursor()
        sql_statement = "SELECT COUNT(*) from %s" % table
        try:
            cursor.execute(sql_statement)
            result = cursor.fetchall()
            cursor.close()
            if self.debug:
                print "Number of rows = %d" % result[0]
            return result

        except MySQLdb.Error, e:
            print "Error: unable to connect to database"
            print "Error %d: %s" % (e.args[0], e.args[1])
            return 0

    def anonymize_email(self, table='MyTable', column='MyColumn', hash_email=False):
        cursor_fetch = self.connection.cursor()
        # Assumes that table has column 'id'
        sql_statement = "SELECT id from %s" % table
        try:
            cursor_fetch.execute(sql_statement)
            results = cursor_fetch.fetchall()
            try:
                cursor_update = self.connection.cursor()
                email_number = 1
                for row in results:
                    if hash_email:
                        new_email = "{\"%s+%d@%s\": 1}" % (self.email_user, email_number, self.email_host)
                    else:
                        new_email = "%s+%d@%s" % (self.email_user, email_number, self.email_host)
                    sql_statement = \
                        "UPDATE %s SET %s = '%s' WHERE id = '%s' " % (table, column, new_email, row[0])
                    if self.debug:
                        print sql_statement
                    cursor_update.execute(sql_statement)
                    email_number += 1
                self.connection.commit()
                cursor_update.close()

            except MySQLdb.Error, e:
                    print "Error: Couldn't update %s.%s with new email address" % (table, column)
                    print "Error %d: %s" % (e.args[0], e.args[1])
                    self.connection.rollback()
            cursor_fetch.close()

        except MySQLdb.Error, e:
            print "Error: unable to fetch data"
            print "Error %d: %s" % (e.args[0], e.args[1])

    def destroy_connection(self):
        self.connection.close()

# Example
#db_connection = DatabaseAnonymizer('localhost', 'user', 'password', 'database', 'myemail', 'gmail.com')
#user_count = db_connection.count_rows('userTable')
#db_connection.anonymize_email('userTable', 'email')
#db_connection.anonymize_email('docTable', 'emailhash', True)
#db_connection.destroy_connection()