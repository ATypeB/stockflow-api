
import { describe, it, expect } from "vitest";
import request from "supertest";
import app from "../src/app.js";

describe("Product API", () => {
  let createdProductId: string;

  it("deve listar todos os produtos", async () => {
    const response = await request(app).get("/products");

    expect(response.status).toBe(200);
    expect(response.body).toBeInstanceOf(Array);
    expect(response.body.length).toBeGreaterThanOrEqual(2);
  });

  it("deve consultar um produto pelo ID", async () => {
    const response = await request(app).get("/products/1");

    expect(response.status).toBe(200);
    expect(response.body.name).toBe("Teclado");
  });

  it("deve retornar 404 para produto inexistente", async () => {
    const response = await request(app).get("/products/id-inexistente");

    expect(response.status).toBe(404);
  });

  it("deve criar um produto", async () => {
    const response = await request(app)
      .post("/products")
      .send({
        name: "Notebook",
        description: "Notebook para testes",
        quantity: 5,
        price: 3500
      });

    expect(response.status).toBe(201);
    expect(response.body.id).toBeDefined();
    expect(response.body.name).toBe("Notebook");

    createdProductId = response.body.id;
  });

  it("deve rejeitar dados inválidos", async () => {
    const response = await request(app)
      .post("/products")
      .send({
        name: "",
        description: "Produto inválido",
        quantity: -5,
        price: 100
      });

    expect(response.status).toBe(400);
  });

  it("deve atualizar um produto", async () => {
    const response = await request(app)
      .put(`/products/${createdProductId}`)
      .send({
        name: "Notebook atualizado",
        description: "Notebook atualizado para testes",
        quantity: 10,
        price: 4000
      });

    expect(response.status).toBe(200);
    expect(response.body.name).toBe("Notebook atualizado");
    expect(response.body.quantity).toBe(10);
  });

  it("deve excluir um produto", async () => {
    const response = await request(app)
      .delete(`/products/${createdProductId}`);

    expect(response.status).toBe(204);
  });

  it("não deve encontrar um produto após sua exclusão", async () => {
    const response = await request(app)
      .get(`/products/${createdProductId}`);

    expect(response.status).toBe(404);
  });
});
