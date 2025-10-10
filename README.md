# 🍼 Napphy Services

**Napphy Services** es una aplicación móvil multiplataforma (Android e iOS) desarrollada en **Flutter** que conecta a padres o tutores con niñeras y cuidadores confiables.

## 📱 Características Principales

### 👶 Para Niñeras/Trabajadores
- ✅ Registro con perfil completo (edad, certificaciones, disponibilidad, ubicación, tarifa)
- ✅ Perfil editable con foto y biografía
- ✅ Recepción de solicitudes de contratación
- ✅ Chat en tiempo real con los padres
- ✅ Historial de contrataciones
- ✅ Sistema de calificaciones y reseñas
- ✅ Estado de disponibilidad actualizable

### 👨‍👩‍👧 Para Padres/Contratantes
- ✅ Búsqueda de niñeras con filtros avanzados (ubicación, precio, calificación)
- ✅ Visualización de perfiles completos
- ✅ Envío de solicitudes de contratación
- ✅ Chat en tiempo real con las niñeras
- ✅ Sistema de notificaciones push
- ✅ Historial de contrataciones
- ✅ Sistema de calificación de servicios

### 🔐 Para Administradores
- ✅ Panel administrativo completo
- ✅ Gestión de usuarios (niñeras y padres)
- ✅ Aprobación/rechazo de registros de niñeras
- ✅ Edición y suspensión de usuarios
- ✅ Reportes de actividad y estadísticas
- ✅ Gestión de contrataciones y calificaciones

## 🛠 Tecnologías Utilizadas

- **Framework**: Flutter 3.0+
- **Lenguaje**: Dart
- **Backend**: Firebase
  - Firebase Authentication (autenticación)
  - Cloud Firestore (base de datos)
  - Firebase Storage (almacenamiento de archivos)
  - Firebase Messaging (notificaciones push)
- **State Management**: Provider
- **Mapas**: Google Maps Flutter
- **UI/UX**: Material Design 3

## 📁 Estructura del Proyecto

```
napphy_services/
├── lib/
│   ├── config/
│   │   ├── routes.dart          # Configuración de rutas
│   │   └── theme.dart           # Tema de la aplicación
│   ├── models/
│   │   ├── user_model.dart      # Modelo de usuario base
│   │   ├── nanny_model.dart     # Modelo de niñera
│   │   ├── parent_model.dart    # Modelo de padre
│   │   ├── message_model.dart   # Modelo de mensajes
│   │   ├── booking_model.dart   # Modelo de contrataciones
│   │   └── review_model.dart    # Modelo de reseñas
│   ├── services/
│   │   ├── auth_service.dart         # Servicio de autenticación
│   │   ├── firestore_service.dart    # Servicio de base de datos
│   │   ├── chat_service.dart         # Servicio de chat
│   │   ├── storage_service.dart      # Servicio de almacenamiento
│   │   └── notification_service.dart # Servicio de notificaciones
│   ├── screens/
│   │   ├── auth/                     # Pantallas de autenticación
│   │   ├── nanny/                    # Pantallas para niñeras
│   │   ├── parent/                   # Pantallas para padres
│   │   ├── admin/                    # Pantallas administrativas
│   │   ├── chat/                     # Pantallas de chat
│   │   └── common/                   # Pantallas comunes
│   ├── widgets/                      # Widgets reutilizables
│   └── main.dart                     # Punto de entrada
├── pubspec.yaml                      # Dependencias del proyecto
└── README.md                         # Este archivo
```

## 🚀 Instalación y Configuración

### Prerequisitos

1. **Flutter SDK**: [Instalar Flutter](https://flutter.dev/docs/get-started/install)
2. **Dart SDK**: Incluido con Flutter
3. **Android Studio** o **VS Code** con extensiones de Flutter
4. **Cuenta de Firebase**: [Firebase Console](https://console.firebase.google.com/)

### Pasos de Instalación

1. **Clonar el repositorio**
```bash
git clone <url-del-repositorio>
cd napphy_services
```

2. **Instalar dependencias**
```bash
flutter pub get
```

3. **Configurar Firebase** (Ver [FIREBASE_SETUP.md](./FIREBASE_SETUP.md))
   - Crear proyecto en Firebase Console
   - Añadir aplicaciones Android e iOS
   - Descargar archivos de configuración
   - Configurar servicios de Firebase

4. **Ejecutar la aplicación**
```bash
# Para Android
flutter run

# Para iOS (requiere Mac)
cd ios && pod install && cd ..
flutter run
```

## 🔥 Configuración de Firebase

Para configurar Firebase en tu proyecto, sigue la guía detallada en [FIREBASE_SETUP.md](./FIREBASE_SETUP.md).

### Servicios de Firebase Requeridos

- ✅ Authentication (Email/Password)
- ✅ Cloud Firestore
- ✅ Cloud Storage
- ✅ Cloud Messaging
- ✅ Firebase Analytics (opcional)

## 📊 Arquitectura del Proyecto

La aplicación sigue una arquitectura limpia y modular:

```
┌─────────────────────────────────────┐
│         UI Layer (Screens)          │
│  - Authentication Screens           │
│  - Nanny Screens                    │
│  - Parent Screens                   │
│  - Admin Screens                    │
│  - Chat Screens                     │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│    State Management (Provider)      │
│  - AuthService                      │
│  - FirestoreService                 │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│       Business Logic Layer          │
│  - Services                         │
│  - Models                           │
│  - Utils                            │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│         Data Layer (Firebase)       │
│  - Authentication                   │
│  - Firestore Database               │
│  - Storage                          │
│  - Messaging                        │
└─────────────────────────────────────┘
```

## 🎨 Pantallas de la Aplicación

### Pantallas de Autenticación
- **Splash Screen**: Pantalla inicial con logo
- **Login Screen**: Inicio de sesión
- **Role Selection**: Selección de rol (Niñera/Padre)
- **Register Screen**: Registro de usuarios

### Pantallas de Niñeras
- **Nanny Home**: Dashboard principal
- **Nanny Profile**: Perfil editable
- **Bookings List**: Lista de contrataciones

### Pantallas de Padres
- **Parent Home**: Dashboard con búsqueda
- **Search Nannies**: Búsqueda con filtros
- **Nanny Detail**: Perfil detallado de niñera
- **Booking Form**: Formulario de contratación

### Pantallas de Administrador
- **Admin Dashboard**: Panel de control
- **Pending Nannies**: Aprobación de niñeras
- **Users Management**: Gestión de usuarios

### Pantallas Comunes
- **Chat List**: Lista de conversaciones
- **Chat Screen**: Chat en tiempo real
- **Notifications**: Notificaciones
- **Settings**: Configuración

## 🔐 Seguridad

- ✅ Autenticación segura con Firebase Auth
- ✅ Reglas de seguridad en Firestore
- ✅ Validación de datos en cliente y servidor
- ✅ Encriptación de datos sensibles
- ✅ Sistema de aprobación de niñeras

## 📱 Características Técnicas

### Funcionalidades Implementadas

1. **Sistema de Autenticación**
   - Registro con email y contraseña
   - Inicio de sesión
   - Recuperación de contraseña
   - Persistencia de sesión

2. **Base de Datos en Tiempo Real**
   - Operaciones CRUD para usuarios
   - Streams para actualizaciones en tiempo real
   - Consultas complejas con filtros

3. **Sistema de Chat**
   - Mensajería en tiempo real
   - Indicadores de mensajes no leídos
   - Historial de conversaciones

4. **Sistema de Notificaciones**
   - Push notifications
   - Notificaciones locales
   - Alertas de nuevas contrataciones

5. **Geolocalización**
   - Búsqueda por ubicación
   - Integración con Google Maps
   - Cálculo de distancias

6. **Sistema de Calificaciones**
   - Reseñas de servicios
   - Cálculo de rating promedio
   - Historial de calificaciones

## 🎯 Próximas Características

- [ ] Pagos integrados (Stripe/PayPal)
- [ ] Verificación de identidad
- [ ] Sistema de favoritos
- [ ] Modo oscuro completo
- [ ] Seguimiento GPS en tiempo real
- [ ] Videollamadas integradas
- [ ] Sistema de recomendaciones con IA

## 🧪 Testing

```bash
# Ejecutar tests
flutter test

# Ejecutar tests con coverage
flutter test --coverage
```

## 📦 Deployment

### Android
```bash
flutter build apk --release
# o
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## 🤝 Contribuciones

Las contribuciones son bienvenidas. Por favor:

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📝 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles.

## 📧 Contacto

- Email: soporte@napphy.com
- Website: www.napphy.com

## 🙏 Agradecimientos

- Flutter Team
- Firebase Team
- Google Maps Platform
- Comunidad de Flutter

---

**Desarrollado con ❤️ usando Flutter**
