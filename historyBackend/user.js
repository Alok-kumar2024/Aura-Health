import mongoose from "mongoose";
const schema = mongoose.Schema;
const userSchema = new schema({
    uid: { type: String, required: true },
    interactions: { type: Object, required: true },
    createdAt: { type: Date }
})
const interactions = mongoose.model("data" , userSchema);
export default interactions;