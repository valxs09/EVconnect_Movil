/**
 * BACKEND - Implementación del Webhook de Stripe
 * 
 * Este archivo muestra cómo implementar el webhook necesario para que
 * el Payment Sheet funcione correctamente con tu backend.
 * 
 * Coloca este código en tu backend (Node.js/Express ejemplo)
 */

// ============================================
// OPCIÓN 1: WEBHOOK (RECOMENDADO)
// ============================================

const express = require('express');
const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);

const router = express.Router();

/**
 * Webhook para recibir eventos de Stripe
 * URL: POST /webhooks/stripe
 * 
 * ⚠️ IMPORTANTE: Este endpoint NO debe tener middleware de bodyParser JSON
 * Stripe requiere el raw body para validar la firma
 */
router.post('/webhooks/stripe', 
  express.raw({ type: 'application/json' }), // Raw body requerido
  async (req, res) => {
    const sig = req.headers['stripe-signature'];
    let event;

    try {
      // Verificar que el evento viene de Stripe
      event = stripe.webhooks.constructEvent(
        req.body,
        sig,
        process.env.STRIPE_WEBHOOK_SECRET // Obtener de Stripe Dashboard
      );
    } catch (err) {
      console.error(`❌ Webhook Error: ${err.message}`);
      return res.status(400).send(`Webhook Error: ${err.message}`);
    }

    // Manejar el evento setup_intent.succeeded
    if (event.type === 'setup_intent.succeeded') {
      const setupIntent = event.data.object;
      
      console.log('✅ SetupIntent exitoso:', setupIntent.id);
      console.log('📊 Payment Method:', setupIntent.payment_method);
      console.log('📊 Customer:', setupIntent.customer);

      try {
        // Buscar el usuario por su stripe_customer_id
        const user = await User.findOne({
          where: { stripe_customer_id: setupIntent.customer }
        });

        if (!user) {
          console.error('❌ Usuario no encontrado para customer:', setupIntent.customer);
          return res.json({ received: true }); // Aún así responder 200
        }

        // Obtener detalles del PaymentMethod desde Stripe
        const paymentMethod = await stripe.paymentMethods.retrieve(
          setupIntent.payment_method
        );

        // Guardar el método de pago en la base de datos
        const savedCard = await PaymentMethod.create({
          user_id: user.id_usuario,
          payment_method_id: paymentMethod.id,
          tipo: paymentMethod.card.brand, // visa, mastercard, etc.
          ultimos_digitos: paymentMethod.card.last4,
          marca: paymentMethod.card.brand,
          expira_mes: paymentMethod.card.exp_month,
          expira_anio: paymentMethod.card.exp_year,
          es_predeterminado: false // O true si es la primera tarjeta
        });

        console.log('✅ Tarjeta guardada:', savedCard.id_pago);

        // Si es la primera tarjeta, marcarla como predeterminada
        const cardCount = await PaymentMethod.count({
          where: { user_id: user.id_usuario }
        });

        if (cardCount === 1) {
          await savedCard.update({ es_predeterminado: true });
          console.log('✅ Tarjeta marcada como predeterminada');
        }

      } catch (error) {
        console.error('❌ Error al guardar tarjeta:', error);
        // Aún así devolver 200 para que Stripe no reintente
      }
    }

    // Otros eventos que podrías manejar (opcional)
    if (event.type === 'payment_method.detached') {
      const paymentMethod = event.data.object;
      
      // Eliminar de la base de datos si fue desvinculado
      await PaymentMethod.destroy({
        where: { payment_method_id: paymentMethod.id }
      });
      
      console.log('✅ Payment method eliminado:', paymentMethod.id);
    }

    // Responder a Stripe que recibimos el webhook
    res.json({ received: true });
  }
);

module.exports = router;

// ============================================
// Configuración en app.js
// ============================================

/*
const webhookRoutes = require('./routes/webhooks');

// ⚠️ IMPORTANTE: Registrar ANTES de bodyParser
app.use('/webhooks', webhookRoutes);

// Luego tus otros middlewares
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
*/

// ============================================
// OPCIÓN 2: ENDPOINT MANUAL (Alternativa)
// ============================================

/**
 * Endpoint para recuperar el payment_method_id de un SetupIntent
 * POST /api/payment-methods/retrieve-from-setup
 * 
 * Body: { "setup_intent_id": "seti_xxxxx" }
 * 
 * Este endpoint permite al frontend obtener el payment_method_id
 * después de completar el Payment Sheet sin usar webhooks
 */
router.post('/api/payment-methods/retrieve-from-setup', 
  authenticateToken, // Tu middleware de autenticación
  async (req, res) => {
    const { setup_intent_id } = req.body;

    if (!setup_intent_id) {
      return res.status(422).json({
        success: false,
        message: 'setup_intent_id es requerido'
      });
    }

    try {
      // Recuperar el SetupIntent de Stripe
      const setupIntent = await stripe.setupIntents.retrieve(setup_intent_id);

      // Verificar que pertenece al usuario autenticado
      if (setupIntent.customer !== req.user.stripe_customer_id) {
        return res.status(403).json({
          success: false,
          message: 'SetupIntent no pertenece a este usuario'
        });
      }

      // Verificar que se completó exitosamente
      if (setupIntent.status !== 'succeeded') {
        return res.status(400).json({
          success: false,
          message: `SetupIntent no completado. Status: ${setupIntent.status}`
        });
      }

      // Extraer el payment_method_id
      const paymentMethodId = setupIntent.payment_method;

      if (!paymentMethodId) {
        return res.status(400).json({
          success: false,
          message: 'No se encontró payment_method_id en el SetupIntent'
        });
      }

      res.json({
        success: true,
        data: {
          payment_method_id: paymentMethodId
        }
      });

    } catch (error) {
      console.error('Error al recuperar SetupIntent:', error);
      res.status(500).json({
        success: false,
        message: 'Error al recuperar información de Stripe'
      });
    }
  }
);

// ============================================
// CONFIGURACIÓN EN STRIPE DASHBOARD
// ============================================

/*
1. Ve a: https://dashboard.stripe.com/webhooks
2. Click en "+ Add endpoint"
3. URL del endpoint: https://tu-backend.com/webhooks/stripe
4. Selecciona estos eventos:
   - setup_intent.succeeded
   - payment_method.detached (opcional)
5. Copia el "Signing secret" (comienza con whsec_)
6. Agrégalo a tu .env como STRIPE_WEBHOOK_SECRET

Para desarrollo local con ngrok:
1. Instala ngrok: npm install -g ngrok
2. Ejecuta: ngrok http 3000 (o tu puerto)
3. Usa la URL de ngrok en Stripe Dashboard
4. Stripe enviará webhooks a tu localhost a través de ngrok
*/

// ============================================
// TESTING DEL WEBHOOK
// ============================================

/*
Usar Stripe CLI para probar webhooks localmente:

1. Instalar Stripe CLI:
   https://stripe.com/docs/stripe-cli

2. Login:
   stripe login

3. Forward webhooks a localhost:
   stripe listen --forward-to localhost:3000/webhooks/stripe

4. Esto te dará un webhook secret temporal (whsec_...)
   Úsalo en tu .env como STRIPE_WEBHOOK_SECRET

5. Hacer una prueba:
   stripe trigger setup_intent.succeeded

6. Ver logs en tiempo real:
   Los verás en la terminal donde ejecutaste stripe listen
*/

// ============================================
// VARIABLES DE ENTORNO NECESARIAS
// ============================================

/*
# .env
STRIPE_SECRET_KEY=sk_test_xxxxxxxxxxxxx
STRIPE_WEBHOOK_SECRET=whsec_xxxxxxxxxxxxx

# Para producción
STRIPE_SECRET_KEY=sk_live_xxxxxxxxxxxxx
STRIPE_WEBHOOK_SECRET=whsec_xxxxxxxxxxxxx
*/
