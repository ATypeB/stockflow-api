
import { Router } from "express";
import {
  getAllProducts,
  getProductById,
  createProduct,
  updateProduct,
  deleteProduct
} from "../services/productService.js";

const router = Router();

// Listar todos os produtos
router.get("/", (_req, res) => {
  res.status(200).json(getAllProducts());
});

// Consultar produto por ID
router.get("/:id", (req, res) => {
  const product = getProductById(req.params.id);

  if (!product) {
    return res.status(404).json({
      message: "Produto não encontrado."
    });
  }

  res.status(200).json(product);
});

// Criar produto
router.post("/", (req, res) => {
  const { name, description, quantity, price } = req.body ?? {};

  if (
    typeof name !== "string" || !name.trim() ||
    typeof description !== "string" ||
    !Number.isInteger(quantity) || quantity < 0 ||
    typeof price !== "number" || !Number.isFinite(price) || price < 0
  ) {
    return res.status(400).json({
      message: "Dados do produto inválidos."
    });
  }

  const product = createProduct({
    name: name.trim(),
    description,
    quantity,
    price
  });

  res.status(201).json(product);
});

// Atualizar produto
router.put("/:id", (req, res) => {
  const { name, description, quantity, price } = req.body ?? {};

  if (
    typeof name !== "string" || !name.trim() ||
    typeof description !== "string" ||
    !Number.isInteger(quantity) || quantity < 0 ||
    typeof price !== "number" || !Number.isFinite(price) || price < 0
  ) {
    return res.status(400).json({
      message: "Dados do produto inválidos."
    });
  }

  const product = updateProduct(req.params.id, {
    name: name.trim(),
    description,
    quantity,
    price
  });

  if (!product) {
    return res.status(404).json({
      message: "Produto não encontrado."
    });
  }

  res.status(200).json(product);
});

// Excluir produto
router.delete("/:id", (req, res) => {
  const deleted = deleteProduct(req.params.id);

  if (!deleted) {
    return res.status(404).json({
      message: "Produto não encontrado."
    });
  }

  res.status(204).send();
});

export default router;
