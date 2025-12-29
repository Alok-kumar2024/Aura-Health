from neo4j import GraphDatabase
import os
from dotenv import load_dotenv
load_dotenv()
PASSWORD = os.getenv("NEO4J_PASSWORD")
URI = "neo4j+s://38a2b6e5.databases.neo4j.io"
USERNAME = "neo4j"


driver = GraphDatabase.driver(URI, auth=(USERNAME, PASSWORD))

def find_interactions(drug: str, food: str):
    query = """
    MATCH (d:Drug {name: $drug})-[r]->(f:Food)
    WHERE toLower(f.name) CONTAINS toLower($food)
      AND type(r) IN ["NEGATIVE_INTERACTION", "POSITIVE_INTERACTION"]
    RETURN
      d.name AS drug,
      f.name AS food,
      type(r) AS relation,
      r.reason AS reason,
      r.alternatives AS alternatives
    """

    with driver.session() as session:
        results = session.run(query, drug=drug, food=food)
        return [record.data() for record in results]
