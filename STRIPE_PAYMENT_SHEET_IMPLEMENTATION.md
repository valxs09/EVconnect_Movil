# Implementación de Payment Sheet con Stripe

## ✅ Implementación Actual

Se ha implementado el flujo de Payment Sheet de Stripe para agregar métodos de pago de forma segura.

### Flujo Implementado

1. **Frontend**: Usuario presiona "Agregar Tarjeta"
2. **Backend**: Se llama a `POST /api/payment-methods/setup` para obtener `client_secret`
3. **Frontend**: Se inicializa y presenta el Payment Sheet de Stripe con el `client_secret`
4. **Stripe**: El usuario ingresa sus datos de tarjeta en el modal nativo de Stripe
5. **Stripe**: Confirma el SetupIntent y vincula la tarjeta al Customer automáticamente
6. **Backend**: Recibe webhook `setup_intent.succeeded` de Stripe (automático)
7. **Frontend**: Verifica que la tarjeta aparezca en la lista de métodos de pago

### Archivos Modificados

#### `lib/screens/payments/payment_screen.dart`
- ✅ Eliminados campos manuales de captura de tarjeta
- ✅ Implementado botón para abrir Payment Sheet
- ✅ UI mejorada con características de seguridad
- ✅ Manejo de errores de Stripe (incluyendo cancelaciones)

#### `lib/services/payment_service.dart`
- ✅ Método `createSetupIntent()` - Obtiene client_secret del backend
- ✅ Método `savePaymentMethod()` - Guarda payment_method_id en backend
- ✅ Método `retrievePaymentMethodFromSetupIntent()` - Para opción alternativa
- ✅ Método `verifyAndSaveLatestPaymentMethod()` - Verifica tarjeta agregada

---

## 🔄 Opciones de Implementación

### Opción 1: Webhooks (ACTUAL - Recomendado por Stripe)

**Ventajas:**
- ✅ Más robusto y seguro
- ✅ No requiere lógica adicional en el frontend
- ✅ Stripe maneja la confirmación automáticamente
- ✅ Funciona con los endpoints existentes

**Flujo:**
```
Usuario → Payment Sheet → Stripe confirma → 
Webhook a backend → Backend guarda tarjeta → 
Frontend verifica lista de tarjetas
```

**Requisitos en Backend:**
- ✅ Endpoint existente: `POST /api/payment-methods/setup`
- ✅ Endpoint existente: `GET /api/payment-methods`
- ⚠️ **REQUERIDO**: Webhook configurado en Stripe para `setup_intent.succeeded`

**Implementación del Webhook en Backend (ejemplo Node.js/Express):**
```javascript
// POST /webhooks/stripe
app.post('/webhooks/stripe', async (req, res) => {
  const sig = req.headers['stripe-signature'];
  let event;

  try {
    event = stripe.webhooks.constructEvent(
      req.body,
      sig,
      process.env.STRIPE_WEBHOOK_SECRET
    );
  } catch (err) {
    return res.status(400).send(`Webhook Error: ${err.message}`);
  }

  // Manejar el evento setup_intent.succeeded
  if (event.type === 'setup_intent.succeeded') {
    const setupIntent = event.data.object;
    const paymentMethodId = setupIntent.payment_method;
    const customerId = setupIntent.customer;

    // Buscar usuario por customer_id
    const user = await User.findOne({ stripe_customer_id: customerId });
    
    if (user) {
      // Guardar el payment_method_id en la base de datos
      await PaymentMethod.create({
        user_id: user.id,
        payment_method_id: paymentMethodId,
        // ... otros campos
      });
    }
  }

  res.json({ received: true });
});
```

---

### Opción 2: Recuperación Manual del PaymentMethod

**Ventajas:**
- ✅ Control inmediato en el frontend
- ✅ No depende de webhooks

**Desventajas:**
- ❌ Requiere endpoint adicional en backend
- ❌ Más complejo
- ❌ No es la forma recomendada por Stripe

**Flujo:**
```
Usuario → Payment Sheet → Stripe confirma → 
Frontend pide payment_method_id → Backend consulta Stripe → 
Backend extrae payment_method_id → Frontend lo guarda vía POST /api/payment-methods
```

**Endpoint Adicional Requerido en Backend:**
```javascript
// POST /api/payment-methods/retrieve-from-setup
app.post('/api/payment-methods/retrieve-from-setup', async (req, res) => {
  const { setup_intent_id } = req.body;
  
  try {
    // Recuperar el SetupIntent de Stripe
    const setupIntent = await stripe.setupIntents.retrieve(setup_intent_id);
    
    if (setupIntent.status !== 'succeeded') {
      return res.status(400).json({
        success: false,
        message: 'SetupIntent no completado'
      });
    }

    // Extraer el payment_method_id
    const paymentMethodId = setupIntent.payment_method;

    res.json({
      success: true,
      data: {
        payment_method_id: paymentMethodId
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});
```

**Luego el frontend llama a:**
```dart
final paymentMethodId = await PaymentService
    .retrievePaymentMethodFromSetupIntent(clientSecret);
    
await PaymentService.savePaymentMethod(paymentMethodId);
```

---

## 🎯 Recomendación

**Usa la Opción 1 (Webhooks)** porque:

1. Es la forma oficial recomendada por Stripe
2. Más robusto ante fallos de red
3. No requiere cambios adicionales en el backend (solo configurar webhook)
4. Ya está implementada en el código actual

### Configuración del Webhook en Stripe:

1. Ve a https://dashboard.stripe.com/webhooks
2. Crea un nuevo webhook endpoint
3. URL: `https://tubackend.com/webhooks/stripe`
4. Eventos a escuchar: `setup_intent.succeeded`
5. Copia el "Signing secret" y guárdalo en tu backend

---

## 🧪 Pruebas

### Tarjetas de Prueba de Stripe:
- **Éxito**: `4242 4242 4242 4242`
- **Requiere autenticación**: `4000 0025 0000 3155`
- **Rechazada**: `4000 0000 0000 9995`

Cualquier fecha futura y CVC de 3 dígitos funcionan para pruebas.

---

## 📱 Experiencia de Usuario

1. Usuario presiona "Agregar Tarjeta"
2. Se muestra un loading
3. Se abre el modal nativo de Stripe (Payment Sheet)
4. Usuario ingresa datos de tarjeta
5. Stripe valida y procesa
6. Modal se cierra automáticamente si es exitoso
7. Se muestra mensaje de éxito
8. Usuario regresa a la pantalla anterior

---

## 🔐 Seguridad

- ✅ Los datos de la tarjeta NUNCA pasan por tu backend
- ✅ Stripe maneja toda la validación y encriptación
- ✅ Cumple con PCI-DSS automáticamente
- ✅ Certificación de nivel bancario

---

## 🐛 Solución de Problemas

### "No se pudo crear el SetupIntent"
- Verificar que el backend esté respondiendo en `POST /api/payment-methods/setup`
- Revisar que el token de autenticación sea válido
- Verificar logs del backend

### "La tarjeta se procesó pero no aparece"
- El webhook puede tardar 1-5 segundos en procesarse
- Verificar que el webhook esté configurado correctamente en Stripe
- Revisar logs del webhook en el dashboard de Stripe
- Implementar reintentos automáticos o botón de "Refrescar"

### "Operación cancelada"
- Es normal, el usuario cerró el Payment Sheet
- No requiere acción

---

## 📝 Notas Importantes

1. **No afecta el flujo de carga**: Los cambios solo afectan `payment_screen.dart` y `payment_service.dart`
2. **Compatibilidad**: Funciona en Android e iOS (Stripe ya está configurado en `main.dart`)
3. **Testing**: Usar modo de prueba de Stripe durante desarrollo
4. **Producción**: Cambiar a claves de producción cuando estés listo

---

## 🚀 Siguiente Paso Recomendado

**Implementar el webhook en el backend** para que el flujo sea completamente funcional.

Si prefieres no usar webhooks, puedes implementar la Opción 2 agregando el endpoint `/api/payment-methods/retrieve-from-setup` y modificando una línea en `payment_screen.dart`.
