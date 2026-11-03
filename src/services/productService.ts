
import { randomUUID } from "node:crypto";

export interface Product {
  id: string;
  name: string;
  description: string;
  quantity: number;
  price: number;
}

export type ProductInput = Omit<Product, "id">;

// Armazenamento temporário em memória
const products: Product[] = [
  {
    id: "1",
    name: "Teclado",
    description: "Teclado mecânico",
    quantity: 10,
    price: 199.90
  },
  {
    id: "2",
    name: "Mouse",
    description: "Mouse óptico",
    quantity: 15,
    price: 89.90
  }
];

export function getAllProducts(): Product[] {
  return products;
}

export function getProductById(id: string): Product | undefined {
  return products.find(product => product.id === id);
}

export function createProduct(data: ProductInput): Product {
  const product: Product = {
    id: randomUUID(),
    ...data
  };

  products.push(product);

  return product;
}

export function updateProduct(
  id: string,
  data: ProductInput
): Product | undefined {
  const index = products.findIndex(product => product.id === id);

  if (index === -1) {
    return undefined;
  }

  products[index] = {
    id,
    ...data
  };

  return products[index];
}

export function deleteProduct(id: string): boolean {
  const index = products.findIndex(product => product.id === id);

  if (index === -1) {
    return false;
  }

  products.splice(index, 1);

  return true;
}
