# mobile_products_app

Aplicación de e-commerce construida en Flutter, con Backend as a Service (BaaS) en Firebase. Permite
gestionar productos y categorías, facilitando la administración y compra de artículos en distintas
categorías.

A new Flutter project.

## Backend API (Firebase Functions)

**URL base:** https://us-central1-mobile-products-90c85.cloudfunctions.net

### Endpoints disponibles

- **POST /createCategory**
    - Descripción: Crea una nueva categoría.
    - Body: `{ "name": "nombre_categoria" }`
    - Respuesta: `{ "id": "id_categoria" }`

- **POST /createProduct**
    - Descripción: Crea un nuevo producto.
    - Body:
      `{ "name": "nombre", "description": "desc", "price": 100, "imageUrl": "url", "category": "nombre_categoria", "stock": 10 }`
    - Respuesta: `{ "id": "id_producto" }`

- **GET /getProducts**
    - Descripción: Obtiene todos los productos.
    - Respuesta: `[{ "id": "id_producto", "name": "nombre", ... }]`

- **PUT /updateProduct**
    - Descripción: Actualiza un producto existente.
    - Body: `{ "id": "id_producto", "name": "nuevo_nombre", ... }`
    - Respuesta: `{ "message": "Producto actualizado" }`

- **DELETE /deleteProduct**
    - Descripción: Elimina un producto por ID.
    - Body: `{ "id": "id_producto" }`
    - Respuesta: `{ "message": "Producto eliminado" }`

- **POST /increaseStock**
    - Descripción: Aumenta el stock de un producto.
    - Body: `{ "id": "id_producto", "quantity": 5 }`
    - Respuesta: `{ "message": "Stock actualizado", "newStock": cantidad }`
