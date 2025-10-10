# 🔥 Guía de Configuración de Firebase

Esta guía te ayudará a configurar Firebase para la aplicación Napphy Services.

## 📋 Índice

1. [Crear Proyecto en Firebase](#1-crear-proyecto-en-firebase)
2. [Configurar Android](#2-configurar-android)
3. [Configurar iOS](#3-configurar-ios)
4. [Configurar Authentication](#4-configurar-authentication)
5. [Configurar Firestore](#5-configurar-firestore)
6. [Configurar Storage](#6-configurar-storage)
7. [Configurar Messaging](#7-configurar-messaging)
8. [Reglas de Seguridad](#8-reglas-de-seguridad)

---

## 1. Crear Proyecto en Firebase

### Paso 1: Crear el Proyecto

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Haz clic en "Agregar proyecto"
3. Nombre del proyecto: `napphy-services` (o el nombre que prefieras)
4. Acepta los términos y condiciones
5. Habilita Google Analytics (opcional pero recomendado)
6. Haz clic en "Crear proyecto"

### Paso 2: Actualizar el Plan (Opcional)

Para producción, considera actualizar al plan Blaze (pago por uso) para obtener:
- Más cuota de almacenamiento
- Cloud Functions
- Mayor límite de operaciones

---

## 2. Configurar Android

### Paso 1: Registrar la App Android

1. En Firebase Console, haz clic en el ícono de Android
2. Nombre del paquete: `com.napphy.services` (debe coincidir con el de tu app)
3. Nombre de la app (opcional): `Napphy Services`
4. Certificado SHA-1 (opcional, necesario para autenticación de Google)

### Paso 2: Descargar google-services.json

1. Descarga el archivo `google-services.json`
2. Colócalo en: `android/app/google-services.json`

### Paso 3: Configurar build.gradle

**android/build.gradle** (nivel de proyecto):
```gradle
buildscript {
    dependencies {
        // Agrega esta línea
        classpath 'com.google.gms:google-services:4.3.15'
    }
}
```

**android/app/build.gradle** (nivel de app):
```gradle
// Al final del archivo, agrega:
apply plugin: 'com.google.gms.google-services'
```

### Paso 4: Configurar AndroidManifest.xml

**android/app/src/main/AndroidManifest.xml**:
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Permisos necesarios -->
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
    <uses-permission android:name="android.permission.CAMERA"/>
    
    <application
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher"
        android:label="Napphy Services">
        
        <!-- Configuración de notificaciones -->
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_channel_id"
            android:value="napphy_channel"/>
            
        <!-- ... resto de la configuración ... -->
    </application>
</manifest>
```

---

## 3. Configurar iOS

### Paso 1: Registrar la App iOS

1. En Firebase Console, haz clic en el ícono de iOS
2. Bundle ID: `com.napphy.services` (debe coincidir con el de Xcode)
3. Nombre de la app (opcional): `Napphy Services`

### Paso 2: Descargar GoogleService-Info.plist

1. Descarga el archivo `GoogleService-Info.plist`
2. Abre el proyecto iOS en Xcode: `open ios/Runner.xcworkspace`
3. Arrastra `GoogleService-Info.plist` a la carpeta `Runner` en Xcode
4. Asegúrate de que "Copy items if needed" esté marcado
5. Target debe ser "Runner"

### Paso 3: Configurar Podfile

**ios/Podfile**:
```ruby
platform :ios, '12.0'

# Descomenta esta línea para definir una versión de Swift
# ENV['SWIFT_VERSION'] = '5.0'

target 'Runner' do
  use_frameworks!
  use_modular_headers!

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
    end
  end
end
```

### Paso 4: Instalar Pods

```bash
cd ios
pod install
cd ..
```

### Paso 5: Configurar Capabilities en Xcode

1. Abre `ios/Runner.xcworkspace` en Xcode
2. Selecciona el target "Runner"
3. Ve a "Signing & Capabilities"
4. Agrega las siguientes capabilities:
   - Push Notifications
   - Background Modes → Remote notifications
   - Location When In Use Usage

### Paso 6: Configurar Info.plist

**ios/Runner/Info.plist**:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Necesitamos tu ubicación para encontrar niñeras cercanas</string>

<key>NSCameraUsageDescription</key>
<string>Necesitamos acceso a la cámara para tu foto de perfil</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>Necesitamos acceso a tus fotos para tu foto de perfil</string>

<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>remote-notification</string>
</array>
```

---

## 4. Configurar Authentication

### Paso 1: Habilitar Authentication

1. En Firebase Console, ve a "Authentication"
2. Haz clic en "Comenzar"
3. Ve a la pestaña "Sign-in method"

### Paso 2: Habilitar Proveedores

Habilita los siguientes métodos de autenticación:

1. **Email/Password**
   - Haz clic en "Email/Password"
   - Activa "Email/Password"
   - Guarda los cambios

2. **Google Sign-In (Opcional)**
   - Haz clic en "Google"
   - Activa Google Sign-In
   - Configura el correo de soporte
   - Guarda los cambios

### Paso 3: Configurar Plantillas de Email (Opcional)

1. Ve a "Templates"
2. Personaliza las plantillas de:
   - Verificación de email
   - Recuperación de contraseña
   - Cambio de email

---

## 5. Configurar Firestore

### Paso 1: Crear Base de Datos

1. En Firebase Console, ve a "Firestore Database"
2. Haz clic en "Crear base de datos"
3. Selecciona "Comenzar en modo de prueba" (temporal)
4. Selecciona la ubicación (preferiblemente cercana a tus usuarios)
5. Haz clic en "Habilitar"

### Paso 2: Estructura de Colecciones

Crea las siguientes colecciones:

```
/users/{userId}
  - email: string
  - fullName: string
  - role: string (nanny, parent, admin)
  - photoUrl: string (nullable)
  - createdAt: timestamp
  - lastLogin: timestamp
  - isActive: boolean

/nannies/{nannyId}
  - userId: string
  - age: number
  - certifications: array
  - availability: map
  - location: geopoint
  - address: string
  - hourlyRate: number
  - photoUrl: string (nullable)
  - bio: string
  - yearsOfExperience: number
  - languages: array
  - isAvailable: boolean
  - isApproved: boolean
  - rating: number
  - totalReviews: number
  - createdAt: timestamp

/parents/{parentId}
  - userId: string
  - phoneNumber: string (nullable)
  - address: string (nullable)
  - numberOfChildren: number
  - childrenAges: array
  - specialRequirements: string (nullable)
  - createdAt: timestamp

/bookings/{bookingId}
  - parentId: string
  - nannyId: string
  - startDate: timestamp
  - endDate: timestamp
  - startTime: string
  - endTime: string
  - numberOfHours: number
  - hourlyRate: number
  - totalAmount: number
  - status: string
  - specialInstructions: string (nullable)
  - address: string
  - createdAt: timestamp
  - acceptedAt: timestamp (nullable)
  - completedAt: timestamp (nullable)

/chats/{chatId}
  - participants: array
  - lastMessage: string
  - lastMessageTime: timestamp
  - unreadCount: map
  - participantNames: map
  - participantPhotos: map

/chats/{chatId}/messages/{messageId}
  - chatId: string
  - senderId: string
  - receiverId: string
  - content: string
  - type: string
  - timestamp: timestamp
  - isRead: boolean

/reviews/{reviewId}
  - bookingId: string
  - parentId: string
  - nannyId: string
  - rating: number
  - comment: string
  - createdAt: timestamp
  - tags: array
```

---

## 6. Configurar Storage

### Paso 1: Habilitar Storage

1. En Firebase Console, ve a "Storage"
2. Haz clic en "Comenzar"
3. Acepta las reglas de seguridad por defecto (se actualizarán después)
4. Selecciona la ubicación
5. Haz clic en "Listo"

### Paso 2: Estructura de Carpetas

```
/profiles/{userId}/
  - profile.jpg

/chats/{chatId}/
  - image_{timestamp}.jpg

/certifications/{nannyId}/
  - cert_{timestamp}.pdf
```

---

## 7. Configurar Messaging

### Paso 1: Habilitar Cloud Messaging

1. En Firebase Console, ve a "Cloud Messaging"
2. Ya está habilitado por defecto

### Paso 2: Configurar Android

1. No se necesita configuración adicional (ya está en google-services.json)

### Paso 3: Configurar iOS

1. Ve a "Project settings" → "Cloud Messaging"
2. En la sección iOS, sube tu APNs Authentication Key:
   - Ve a [Apple Developer](https://developer.apple.com/account/resources/authkeys/list)
   - Crea un nuevo Key con APNs habilitado
   - Descarga el archivo .p8
   - Sube el archivo a Firebase
   - Ingresa el Key ID y Team ID

---

## 8. Reglas de Seguridad

### Reglas de Firestore

**Firestore Database → Rules**:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Función auxiliar para verificar autenticación
    function isSignedIn() {
      return request.auth != null;
    }
    
    // Función para verificar que el usuario es el propietario
    function isOwner(userId) {
      return isSignedIn() && request.auth.uid == userId;
    }
    
    // Función para verificar si es admin
    function isAdmin() {
      return isSignedIn() && 
             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Reglas para usuarios
    match /users/{userId} {
      allow read: if isSignedIn();
      allow create: if isSignedIn() && isOwner(userId);
      allow update: if isOwner(userId) || isAdmin();
      allow delete: if isAdmin();
    }
    
    // Reglas para niñeras
    match /nannies/{nannyId} {
      allow read: if isSignedIn();
      allow create: if isSignedIn() && isOwner(resource.data.userId);
      allow update: if isOwner(resource.data.userId) || isAdmin();
      allow delete: if isAdmin();
    }
    
    // Reglas para padres
    match /parents/{parentId} {
      allow read: if isSignedIn();
      allow create: if isSignedIn() && isOwner(resource.data.userId);
      allow update: if isOwner(resource.data.userId) || isAdmin();
      allow delete: if isAdmin();
    }
    
    // Reglas para contrataciones
    match /bookings/{bookingId} {
      allow read: if isSignedIn() && 
                     (isOwner(resource.data.parentId) || 
                      isOwner(resource.data.nannyId) || 
                      isAdmin());
      allow create: if isSignedIn();
      allow update: if isSignedIn() && 
                       (isOwner(resource.data.parentId) || 
                        isOwner(resource.data.nannyId) || 
                        isAdmin());
      allow delete: if isAdmin();
    }
    
    // Reglas para chats
    match /chats/{chatId} {
      allow read, write: if isSignedIn() && 
                            request.auth.uid in resource.data.participants;
      
      match /messages/{messageId} {
        allow read: if isSignedIn() && 
                       request.auth.uid in get(/databases/$(database)/documents/chats/$(chatId)).data.participants;
        allow create: if isSignedIn();
        allow update: if isSignedIn() && 
                         (isOwner(resource.data.senderId) || 
                          isOwner(resource.data.receiverId));
      }
    }
    
    // Reglas para reseñas
    match /reviews/{reviewId} {
      allow read: if isSignedIn();
      allow create: if isSignedIn() && isOwner(request.resource.data.parentId);
      allow update, delete: if isAdmin();
    }
  }
}
```

### Reglas de Storage

**Storage → Rules**:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    
    // Función para verificar autenticación
    function isSignedIn() {
      return request.auth != null;
    }
    
    // Reglas para fotos de perfil
    match /profiles/{userId}/{allPaths=**} {
      allow read: if isSignedIn();
      allow write: if isSignedIn() && request.auth.uid == userId &&
                      request.resource.size < 5 * 1024 * 1024 && // Max 5MB
                      request.resource.contentType.matches('image/.*');
    }
    
    // Reglas para imágenes de chat
    match /chats/{chatId}/{allPaths=**} {
      allow read: if isSignedIn();
      allow write: if isSignedIn() &&
                      request.resource.size < 10 * 1024 * 1024 && // Max 10MB
                      request.resource.contentType.matches('image/.*');
    }
    
    // Reglas para certificaciones
    match /certifications/{nannyId}/{allPaths=**} {
      allow read: if isSignedIn();
      allow write: if isSignedIn() && request.auth.uid == nannyId &&
                      request.resource.size < 10 * 1024 * 1024; // Max 10MB
    }
  }
}
```

---

## ✅ Verificación de la Configuración

### Checklist de Configuración

- [ ] Proyecto de Firebase creado
- [ ] App Android registrada y google-services.json configurado
- [ ] App iOS registrada y GoogleService-Info.plist configurado
- [ ] Authentication habilitado (Email/Password)
- [ ] Firestore Database creado y estructura configurada
- [ ] Storage habilitado
- [ ] Cloud Messaging configurado
- [ ] Reglas de seguridad actualizadas
- [ ] APNs configurado para iOS (si aplica)

### Probar la Configuración

1. Ejecuta la app en un dispositivo o emulador
2. Intenta registrarte con un email y contraseña
3. Verifica en Firebase Console que:
   - El usuario aparece en Authentication
   - El documento del usuario se creó en Firestore
4. Prueba el chat para verificar Firestore en tiempo real
5. Prueba subir una foto de perfil para verificar Storage

---

## 🔧 Troubleshooting

### Error: "google-services.json not found"
- Verifica que el archivo esté en `android/app/google-services.json`
- Asegúrate de haber ejecutado `flutter clean` y `flutter pub get`

### Error: "GoogleService-Info.plist not found"
- Verifica que el archivo esté agregado correctamente en Xcode
- Debe estar en el target "Runner"

### Error: Notificaciones no funcionan
- Android: Verifica que el canal de notificaciones esté configurado
- iOS: Verifica que APNs esté configurado correctamente

### Error: Permisos de Firestore denegados
- Verifica que las reglas de seguridad estén actualizadas
- Asegúrate de que el usuario esté autenticado

---

## 📚 Recursos Adicionales

- [Documentación oficial de Firebase](https://firebase.google.com/docs)
- [FlutterFire](https://firebase.flutter.dev/)
- [Firebase CLI](https://firebase.google.com/docs/cli)

---

**¡Configuración completada! 🎉**

Tu aplicación Napphy Services ya está lista para usar todos los servicios de Firebase.
