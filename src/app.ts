
import express from "express";
import productRoutes from "./routes/productRoutes.js";

const app = express();

app.use(express.json());

app.get("/", (_req, res) => {
  res.status(200).json({
    message: "StockFlow API v2: entregue via CD!"
  });
});

app.use("/products", productRoutes);

export default app;
