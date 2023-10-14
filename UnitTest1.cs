﻿using Docker.DotNet.Models;
using DotNet.Testcontainers.Builders;
using DotNet.Testcontainers.Configurations;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Data.Odbc;
using System.Diagnostics;
using System.IO;
using System.Security.Principal;
using System.Text;
using System.Threading.Tasks;
using Testcontainers.PostgreSql;
using Xunit;
using Xunit.Abstractions;
using static System.Net.Mime.MediaTypeNames;

namespace NppDB.PostgreSQL.Tests
{
    public class UnitTest1 : IAsyncLifetime
    {
        private readonly ITestOutputHelper output;

        public UnitTest1(ITestOutputHelper output)
        {
            this.output = output;
        }

        private readonly PostgreSqlContainer _postgreSqlContainer = new PostgreSqlBuilder()
            .WithImage("postgres:15.1")
            .WithDatabase("db")
            .WithUsername("sa")
            .WithPassword("sa")
            .WithResourceMapping(new FileInfo("Resources/PostgreSQL_Scott_json.sql"), "/docker-entrypoint-initdb.d/")
            .WithCleanUp(true)
            .Build();

        public async Task InitializeAsync()
        {
            await _postgreSqlContainer.StartAsync();
        }

        [Fact]
        public async Task Test1()
        {
            PostgreSQLConnect connect = new PostgreSQLConnect
            {
                Account = "sa",
                Password = "sa",
                Database = "db",
                ServerAddress = "127.0.0.1",
                Port = _postgreSqlContainer.GetMappedPublicPort("5432").ToString()
            };
            Comm.ISQLExecutor executor = connect.CreateSQLExecutor();
            List<string> sqlQueries = new List<string>();
            using (var sr = new StreamReader("Resources/queries.sql"))
            {
                String line;
                while ((line = sr.ReadLine()) != null)
                {
                    if (!String.IsNullOrEmpty(line)) 
                    {
                        sqlQueries.Add(line);
                    }
                }
            }
            executor.Execute(sqlQueries, (results) => {
                foreach (var result in results)
                {
                    if (result.Error != null)
                    {
                        output.WriteLine(result.Error.ToString());
                    }
                    else
                    {
                        output.WriteLine(result.CommandText.ToString());
                        output.WriteLine(result.RecordsAffected.ToString());
                        StringBuilder sbCol = new StringBuilder();
                        foreach (DataColumn col in result.QueryResult.Columns)
                        {
                            sbCol.Append(col.ColumnName);
                            sbCol.Append(',');
                        }
                        output.WriteLine(sbCol.ToString());
                        StringBuilder sb = new StringBuilder();
                        foreach (DataRow dataRow in result.QueryResult.Rows)
                        {
                            foreach (var item in dataRow.ItemArray)
                            {
                                sb.Append(item);
                                sb.Append(',');
                            }
                            sb.AppendLine();
                        }
                        output.WriteLine(sb.ToString());
                        //output.WriteLine(result.QueryResult.)
                    }
                    //Assert.Null(result.Error);
                }
            });
        }

        public Task DisposeAsync()
        {
            // When using this method to stop the container like shown in documentation, the container would die while test was still running
            return Task.Delay(10000);
        }
    }
}