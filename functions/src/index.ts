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
  if (req.method !== 'POST') {
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
