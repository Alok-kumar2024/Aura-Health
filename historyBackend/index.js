import express from "express";
import interactions from "./user.js";
import main from "./database.js";
const app = express();
app.use(express.json());


app.post("/getInteractions", async (req, res) => {
  try {
    const { uid, drug, food } = req.body;

    if (!uid || !drug || !food) {
      return res.status(400).json({ error: "uid, drug and food are required" });
    }

    const drugs = Array.isArray(drug) ? drug : [drug];
    const foods = Array.isArray(food) ? food : [food];


    // if (drugs.length * foods.length > 50) {
    //   return res.status(400).json({ error: "Too many drug-food combinations" });
    // }


    const requests = [];

    for (const d of drugs) {
      for (const f of foods) {
        requests.push(
          fetch("https://aura-health-9cvj.onrender.com/check-meal", {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
              drug: d,
              food: f
            })
          })
            .then(r => {
              if (!r.ok) throw new Error("FastAPI failed");
              return r.json();
            })
            .then(data => ({
              drug: d,
              food: f,
              result: data
            }))
        );
      }
    }
    const results = await Promise.all(requests);

    const savedRecord = await interactions.create({
      uid,
      interactions: results,
      createdAt: new Date()
    });

    res.status(200).json(savedRecord);

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to fetch interactions" });
  }
});

app.get("/history" ,async (req ,res) => {

  try {
    const { uid } = req.query; 
    const userDocs = await interactions.find({ uid }).sort({ _id: -1 });

    if (!userDocs || userDocs.length === 0) {
      return res.status(200).json({ 
        message: "No history found for this user", 
        data: [] 
      });
    }
    res.status(200).json({
      count: userDocs.length,
      data: userDocs
    });

  } catch (error) {
    console.error("Error fetching history:", error);
    res.status(500).json({ error: "Internal Server Error" });
  }
})



app.delete("/deleteSingleHistory/:id", async (req, res) => {
  try {
    const { id } = req.params;
    const deletedDoc = await interactions.findByIdAndDelete(id);

    if (!deletedDoc) {
      return res.status(404).json({ error: "Interaction not found" });
    }

    res.status(200).json({ 
      message: "Interaction deleted successfully",
      deletedId: id 
    });

  } catch (error) {
    console.error("Error deleting interaction:", error);
    res.status(500).json({ error: "Failed to delete interaction" });
  }
});
app.delete("/clearHistory", async (req, res) => {
  try {
    const { uid } = req.query; 

    if (!uid) {
      return res.status(400).json({ error: "User ID (uid) is required" });
    }

    const result = await interactions.deleteMany({ uid: String(uid) });

    res.status(200).json({
      message: `Successfully cleared history.`,
      deletedCount: result.deletedCount
    });

  } catch (error) {
    console.error("Error clearing history:", error);
    res.status(500).json({ error: "Failed to clear history" });
  }
});

const port = process.env.PORT || 4000;
main().
then(async ()=>{
    app.listen(port ,'0.0.0.0', ()=>{
        console.log(`listening at port ${port}`);
    })
})
.catch(err => console.log(err));