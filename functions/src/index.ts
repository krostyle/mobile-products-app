/**
 * Import function triggers from their respective submodules:
 *
 * import {onCall} from "firebase-functions/v2/https";
 * import {onDocumentWritten} from "firebase-functions/v2/firestore";
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

import { setGlobalOptions } from 'firebase-functions';
import * as logger from 'firebase-functions/logger';
import { onRequest } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';
admin.initializeApp();

// Start writing functions
// https://firebase.google.com/docs/functions/typescript

// For cost control, you can set the maximum number of containers that can be
// running at the same time. This helps mitigate the impact of unexpected
// traffic spikes by instead downgrading performance. This limit is a
// per-function limit. You can override the limit for each function using the
// `maxInstances` option in the function's options, e.g.
// `onRequest({ maxInstances: 5 }, (req, res) => { ... })`.
// NOTE: setGlobalOptions does not apply to functions using the v1 API. V1
// functions should each use functions.runWith({ maxInstances: 10 }) instead.
// In the v1 API, each function can only serve one request per container, so
// this will be the maximum concurrent request count.
setGlobalOptions({ maxInstances: 10 });

// export const helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

// Crear categoría
export const createCategory = onRequest(async (req, res) => {
  logger.info('createCategory called', { method: req.method, body: req.body });
  if (req.method !== 'POST') {
    res.status(405).send('Método no permitido');
    return;
  }
  const { name } = req.body;
  if (!name) {
    res.status(400).send('Nombre de categoría requerido');
    return;
  }
  try {
    // Verificar si la categoría ya existe
    const snapshot = await admin
      .firestore()
      .collection('categories')
      .where('name', '==', name)
      .get();
    if (!snapshot.empty) {
      res.status(409).send('La categoría ya existe');
      return;
    }
    const docRef = await admin
      .firestore()
      .collection('categories')
      .add({ name });
    res.status(201).send({ id: docRef.id });
  } catch (error) {
    const errorMsg = error instanceof Error ? error.message : String(error);
    res.status(500).send(errorMsg);
  }
});

// Crear producto
export const createProduct = onRequest(async (req, res) => {
  logger.info('createProduct called', { method: req.method, body: req.body });
  if (req.method !== 'POST') {
    res.status(405).send('Método no permitido');
    return;
  }
  const { name, description, price, imageUrl, category, stock } = req.body;
  if (!category) {
    res.status(400).send('Categoría requerida');
    return;
  }
  try {
    // Verificar si la categoría existe
    const catSnapshot = await admin
      .firestore()
      .collection('categories')
      .where('name', '==', category)
      .get();
    if (catSnapshot.empty) {
      res.status(404).send('La categoría no existe');
      return;
    }
    const docRef = await admin.firestore().collection('products').add({
      name,
      description,
      price,
      imageUrl,
      category,
      stock,
    });
    res.status(201).send({ id: docRef.id });
  } catch (error) {
    const errorMsg = error instanceof Error ? error.message : String(error);
    res.status(500).send(errorMsg);
  }
});

// Leer todos los productos
export const getProducts = onRequest(async (req, res) => {
  logger.info('getProducts called', { method: req.method });
  if (req.method !== 'GET') {
    res.status(405).send('Método no permitido');
    return;
  }
  try {
    const snapshot = await admin.firestore().collection('products').get();
    const products = snapshot.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
    }));
    res.status(200).send(products);
  } catch (error) {
    const errorMsg = error instanceof Error ? error.message : String(error);
    res.status(500).send(errorMsg);
  }
});

// Editar producto
export const updateProduct = onRequest(async (req, res) => {
  logger.info('updateProduct called', { method: req.method, body: req.body });
  if (req.method !== 'PUT') {
    res.status(405).send('Método no permitido');
    return;
  }
  const { id, ...data } = req.body;
  if (!id) {
    res.status(400).send('ID requerido');
    return;
  }
  try {
    await admin.firestore().collection('products').doc(id).update(data);
    res.status(200).send({ message: 'Producto actualizado' });
  } catch (error) {
    const errorMsg = error instanceof Error ? error.message : String(error);
    res.status(500).send(errorMsg);
  }
});

// Eliminar producto
export const deleteProduct = onRequest(async (req, res) => {
  logger.info('deleteProduct called', { method: req.method, body: req.body });
  if (req.method !== 'DELETE') {
    res.status(405).send('Método no permitido');
    return;
  }
  const { id } = req.body;
  if (!id) {
    res.status(400).send('ID requerido');
    return;
  }
  try {
    await admin.firestore().collection('products').doc(id).delete();
    res.status(200).send({ message: 'Producto eliminado' });
  } catch (error) {
    const errorMsg = error instanceof Error ? error.message : String(error);
    res.status(500).send(errorMsg);
  }
});

// Aumentar stock de producto
export const increaseStock = onRequest(async (req, res) => {
  logger.info('increaseStock called', { method: req.method, body: req.body });
  if (req.method !== 'PUT') {
    res.status(405).send('Método no permitido');
    return;
  }
  const { id, quantity } = req.body;
  if (!id) {
    res.status(400).send('ID requerido');
    return;
  }
  if (!quantity || quantity <= 0) {
    res.status(400).send('Cantidad debe ser mayor a 0');
    return;
  }
  try {
    const productRef = admin.firestore().collection('products').doc(id);
    const doc = await productRef.get();

    if (!doc.exists) {
      res.status(404).send('Producto no encontrado');
      return;
    }

    const currentStock = doc.data()?.stock || 0;
    const newStock = currentStock + quantity;

    await productRef.update({ stock: newStock });
    res.status(200).send({
      message: 'Stock actualizado',
      previousStock: currentStock,
      newStock: newStock,
    });
  } catch (error) {
    const errorMsg = error instanceof Error ? error.message : String(error);
    res.status(500).send(errorMsg);
  }
});

// Crear proveedor
export const createSupplier = onRequest(async (req, res) => {
  logger.info('createSupplier called', { method: req.method, body: req.body });
  if (req.method !== 'POST') {
    res.status(405).send('Método no permitido');
    return;
  }
  const { name, email, phone, address, productIds } = req.body;
  if (!name) {
    res.status(400).send('Nombre del proveedor requerido');
    return;
  }
  try {
    // Verificar si el proveedor ya existe
    const snapshot = await admin
      .firestore()
      .collection('suppliers')
      .where('name', '==', name)
      .get();
    if (!snapshot.empty) {
      res.status(409).send('El proveedor ya existe');
      return;
    }
    const supplierData = {
      name,
      email: email || null,
      phone: phone || null,
      address: address || null,
      productIds: productIds || [],
    };
    const docRef = await admin
      .firestore()
      .collection('suppliers')
      .add(supplierData);
    res.status(201).send({ id: docRef.id });
  } catch (error) {
    const errorMsg = error instanceof Error ? error.message : String(error);
    res.status(500).send(errorMsg);
  }
});

// Leer todos los proveedores
export const getSuppliers = onRequest(async (req, res) => {
  logger.info('getSuppliers called', { method: req.method });
  if (req.method !== 'GET') {
    res.status(405).send('Método no permitido');
    return;
  }
  try {
    const snapshot = await admin.firestore().collection('suppliers').get();
    const suppliers = snapshot.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
    }));
    res.status(200).send(suppliers);
  } catch (error) {
    const errorMsg = error instanceof Error ? error.message : String(error);
    res.status(500).send(errorMsg);
  }
});

// Obtener proveedor por ID
export const getSupplierById = onRequest(async (req, res) => {
  logger.info('getSupplierById called', { method: req.method });
  if (req.method !== 'GET') {
    res.status(405).send('Método no permitido');
    return;
  }
  const id = req.query.id as string;
  if (!id) {
    res.status(400).send('ID requerido');
    return;
  }
  try {
    const doc = await admin.firestore().collection('suppliers').doc(id).get();
    if (!doc.exists) {
      res.status(404).send('Proveedor no encontrado');
      return;
    }
    res.status(200).send({
      id: doc.id,
      ...doc.data(),
    });
  } catch (error) {
    const errorMsg = error instanceof Error ? error.message : String(error);
    res.status(500).send(errorMsg);
  }
});

// Editar proveedor
export const updateSupplier = onRequest(async (req, res) => {
  logger.info('updateSupplier called', { method: req.method, body: req.body });
  if (req.method !== 'PUT') {
    res.status(405).send('Método no permitido');
    return;
  }
  const { id, ...data } = req.body;
  if (!id) {
    res.status(400).send('ID requerido');
    return;
  }
  try {
    const supplierRef = admin.firestore().collection('suppliers').doc(id);
    const doc = await supplierRef.get();
    if (!doc.exists) {
      res.status(404).send('Proveedor no encontrado');
      return;
    }
    await supplierRef.update(data);
    res.status(200).send({ message: 'Proveedor actualizado' });
  } catch (error) {
    const errorMsg = error instanceof Error ? error.message : String(error);
    res.status(500).send(errorMsg);
  }
});

// Eliminar proveedor
export const deleteSupplier = onRequest(async (req, res) => {
  logger.info('deleteSupplier called', { method: req.method, body: req.body });
  if (req.method !== 'DELETE') {
    res.status(405).send('Método no permitido');
    return;
  }
  const { id } = req.body;
  if (!id) {
    res.status(400).send('ID requerido');
    return;
  }
  try {
    const supplierRef = admin.firestore().collection('suppliers').doc(id);
    const doc = await supplierRef.get();
    if (!doc.exists) {
      res.status(404).send('Proveedor no encontrado');
      return;
    }
    await supplierRef.delete();
    res.status(200).send({ message: 'Proveedor eliminado' });
  } catch (error) {
    const errorMsg = error instanceof Error ? error.message : String(error);
    res.status(500).send(errorMsg);
  }
});

// Agregar producto a proveedor
export const addProductToSupplier = onRequest(async (req, res) => {
  logger.info('addProductToSupplier called', {
    method: req.method,
    body: req.body,
  });
  if (req.method !== 'PUT') {
    res.status(405).send('Método no permitido');
    return;
  }
  const { supplierId, productId } = req.body;
  if (!supplierId || !productId) {
    res.status(400).send('ID de proveedor y producto requeridos');
    return;
  }
  try {
    const supplierRef = admin
      .firestore()
      .collection('suppliers')
      .doc(supplierId);
    const supplierDoc = await supplierRef.get();

    if (!supplierDoc.exists) {
      res.status(404).send('Proveedor no encontrado');
      return;
    }

    // Verificar si el producto existe
    const productDoc = await admin
      .firestore()
      .collection('products')
      .doc(productId)
      .get();
    if (!productDoc.exists) {
      res.status(404).send('Producto no encontrado');
      return;
    }

    const supplierData = supplierDoc.data()!;
    const currentProductIds = supplierData.productIds || [];

    if (currentProductIds.includes(productId)) {
      res
        .status(200)
        .send({ message: 'El producto ya está asignado al proveedor' });
      return;
    }

    const updatedProductIds = [...currentProductIds, productId];
    await supplierRef.update({ productIds: updatedProductIds });

    res.status(200).send({ message: 'Producto agregado al proveedor' });
  } catch (error) {
    const errorMsg = error instanceof Error ? error.message : String(error);
    res.status(500).send(errorMsg);
  }
});

// Remover producto de proveedor
export const removeProductFromSupplier = onRequest(async (req, res) => {
  logger.info('removeProductFromSupplier called', {
    method: req.method,
    body: req.body,
  });
  if (req.method !== 'PUT') {
    res.status(405).send('Método no permitido');
    return;
  }
  const { supplierId, productId } = req.body;
  if (!supplierId || !productId) {
    res.status(400).send('ID de proveedor y producto requeridos');
    return;
  }
  try {
    const supplierRef = admin
      .firestore()
      .collection('suppliers')
      .doc(supplierId);
    const supplierDoc = await supplierRef.get();

    if (!supplierDoc.exists) {
      res.status(404).send('Proveedor no encontrado');
      return;
    }

    const supplierData = supplierDoc.data()!;
    const currentProductIds = supplierData.productIds || [];

    if (!currentProductIds.includes(productId)) {
      res
        .status(200)
        .send({ message: 'El producto no está asignado al proveedor' });
      return;
    }

    const updatedProductIds = currentProductIds.filter(
      (id: string) => id !== productId
    );
    await supplierRef.update({ productIds: updatedProductIds });

    res.status(200).send({ message: 'Producto removido del proveedor' });
  } catch (error) {
    const errorMsg = error instanceof Error ? error.message : String(error);
    res.status(500).send(errorMsg);
  }
});

// Agregar múltiples productos a proveedor
export const addMultipleProductsToSupplier = onRequest(async (req, res) => {
  logger.info('addMultipleProductsToSupplier called', {
    method: req.method,
    body: req.body,
  });
  if (req.method !== 'PUT') {
    res.status(405).send('Método no permitido');
    return;
  }
  const { supplierId, productIds } = req.body;
  if (
    !supplierId ||
    !productIds ||
    !Array.isArray(productIds) ||
    productIds.length === 0
  ) {
    res
      .status(400)
      .send('ID de proveedor y array de IDs de productos requeridos');
    return;
  }
  try {
    const supplierRef = admin
      .firestore()
      .collection('suppliers')
      .doc(supplierId);
    const supplierDoc = await supplierRef.get();

    if (!supplierDoc.exists) {
      res.status(404).send('Proveedor no encontrado');
      return;
    }

    // Verificar que todos los productos existen
    const productRefs = productIds.map((id) =>
      admin.firestore().collection('products').doc(id).get()
    );
    const productDocs = await Promise.all(productRefs);

    const nonExistentProducts = productIds.filter(
      (id, index) => !productDocs[index].exists
    );
    if (nonExistentProducts.length > 0) {
      res
        .status(404)
        .send(`Productos no encontrados: ${nonExistentProducts.join(', ')}`);
      return;
    }

    const supplierData = supplierDoc.data()!;
    const currentProductIds = supplierData.productIds || [];

    // Filtrar productos que ya están asignados
    const newProductIds = productIds.filter(
      (id) => !currentProductIds.includes(id)
    );

    if (newProductIds.length === 0) {
      res.status(200).send({
        message: 'Todos los productos ya están asignados al proveedor',
        alreadyAssigned: productIds.length,
        newlyAdded: 0,
      });
      return;
    }

    const updatedProductIds = [...currentProductIds, ...newProductIds];
    await supplierRef.update({ productIds: updatedProductIds });

    res.status(200).send({
      message: `${newProductIds.length} productos agregados al proveedor`,
      newlyAdded: newProductIds.length,
      alreadyAssigned: productIds.length - newProductIds.length,
      totalProducts: updatedProductIds.length,
    });
  } catch (error) {
    const errorMsg = error instanceof Error ? error.message : String(error);
    res.status(500).send(errorMsg);
  }
});

// Remover múltiples productos de proveedor
export const removeMultipleProductsFromSupplier = onRequest(
  async (req, res) => {
    logger.info('removeMultipleProductsFromSupplier called', {
      method: req.method,
      body: req.body,
    });
    if (req.method !== 'PUT') {
      res.status(405).send('Método no permitido');
      return;
    }
    const { supplierId, productIds } = req.body;
    if (
      !supplierId ||
      !productIds ||
      !Array.isArray(productIds) ||
      productIds.length === 0
    ) {
      res
        .status(400)
        .send('ID de proveedor y array de IDs de productos requeridos');
      return;
    }
    try {
      const supplierRef = admin
        .firestore()
        .collection('suppliers')
        .doc(supplierId);
      const supplierDoc = await supplierRef.get();

      if (!supplierDoc.exists) {
        res.status(404).send('Proveedor no encontrado');
        return;
      }

      const supplierData = supplierDoc.data()!;
      const currentProductIds = supplierData.productIds || [];

      // Filtrar productos que están realmente asignados
      const productsToRemove = productIds.filter((id) =>
        currentProductIds.includes(id)
      );

      if (productsToRemove.length === 0) {
        res.status(200).send({
          message: 'Ninguno de los productos estaba asignado al proveedor',
          removed: 0,
          notAssigned: productIds.length,
        });
        return;
      }

      const updatedProductIds = currentProductIds.filter(
        (id: string) => !productIds.includes(id)
      );
      await supplierRef.update({ productIds: updatedProductIds });

      res.status(200).send({
        message: `${productsToRemove.length} productos removidos del proveedor`,
        removed: productsToRemove.length,
        notAssigned: productIds.length - productsToRemove.length,
        totalProducts: updatedProductIds.length,
      });
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : String(error);
      res.status(500).send(errorMsg);
    }
  }
);
