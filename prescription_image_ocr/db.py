
from neo4j import GraphDatabase
import os
from dotenv import load_dotenv
load_dotenv()
PASSWORD = os.getenv("NEO4J_PASSWORD")
URI = "neo4j+s://38a2b6e5.databases.neo4j.io"
USERNAME = "neo4j"

driver = GraphDatabase.driver(
    URI,
    auth=(USERNAME, PASSWORD),
    max_connection_lifetime=300, 
    connection_timeout=30
)

def get_all_drug_names():
    query = "MATCH (d:Drug) RETURN DISTINCT toLower(d.name) AS name"
    
    with driver.session() as session:
        result = session.run(query)
        return [record["name"] for record in result]
