# Entrega de Turno · TENS

Aplicación Flutter para preparar la **entrega de turno de técnicos en enfermería**.

Es un formulario simple, de arriba hacia abajo, con **un campo por cada línea de
la plantilla**. Al final se genera el mensaje listo para **copiar** en WhatsApp o
para **compartir como imagen**.

## Cómo se usa (3 pasos)

1. **Escribe** en cada casilla (el orden es el de la plantilla de siempre).
2. Toca **Ver mensaje**.
3. Toca **Copiar mensaje** (y pégalo en el grupo) o **Compartir como imagen**.

El campo **Tens a cargo** ya viene con el nombre **Edith Catrilef** escrito
(se puede cambiar y la app recuerda lo que escribas).

## Plantilla que genera

```
*ENTREGA DE TURNO*

*Paciente:* Rosa Martínez
*Fecha:* 03/10/2026
*Tens a cargo:* Edith Catrilef
*Próximo control médico:* Dr. Soto miércoles 10:00
*Próximos exámenes:* Hemograma completo, perfil bioquímico

*Stock crítico de medicamentos:*
Ketorolaco 2 ampollas
Insulina NPH 4 unidades

*Stock de insumos:*
Guantes M 1 caja

*Estado actual del paciente:*
paciente en BEG, al examen físico destaca…, cooperadora, diuresis (+) dep (-).
realiza sus terapias de Kine y TO, durante el día buena ingesta de líquidos,
come su desayuno y almuerzo sin signos de dificultad al tragar. Entrego a la
colega María Fernández.

*Salidas realizadas con el paciente:*
Kinesiología 10:30
Terapia ocupacional 16:00
```

- Los `*asteriscos*` se ven como **negrita** al pegar en WhatsApp.
- Los campos que no se escriben simplemente no aparecen en el mensaje.
- La **imagen** sale en formato formal: fondo blanco, títulos en negrita, línea
  divisoria y sin colores; se guarda con margen blanco, lista para enviar.

## Funciones

- **Formulario lineal**: Paciente · Fecha (calendario) · Tens a cargo ·
  Próximo control médico · Próximos exámenes · Stock crítico de medicamentos ·
  Stock de insumos · Estado actual del paciente · Salidas realizadas.
- Etiquetas grandes siempre visibles y casillas amplias; los campos largos
  **crecen solos** para que nada quede escondido.
- **Ayuda plegada** («¿No sabes cómo escribirlo?») con frases típicas que se
  agregan solas al estado del paciente.
- **Copiar mensaje** al portapapeles con un toque.
- **Compartir como imagen**: genera un PNG en alta resolución (3x), lo guarda y
  abre la hoja de compartir.
- **Autoguardado** del formulario: al volver a abrir la app todo sigue ahí.
- **Entregas guardadas** para reutilizar los datos de un turno anterior.
- Aviso de los campos que quedaron sin escribir antes de enviar.
- El desplazamiento no rebota ni estira las tarjetas, y al tocar fuera de una
  casilla se cierra el teclado.

## Estructura

```
lib/
├── main.dart                     # arranque, tema y localización (es)
├── models/
│   ├── entrega.dart              # campos + armado del mensaje
│   └── demo.dart                 # datos de ejemplo (solo desarrollo)
├── state/entrega_controller.dart # formulario, autoguardado y guardadas
├── screens/
│   ├── llenado.dart              # el formulario
│   ├── mensaje.dart              # copiar / compartir imagen
│   └── guardadas.dart            # entregas guardadas
├── widgets/
│   ├── campo.dart                # etiqueta + casilla, y campo de fecha
│   └── captura_mensaje.dart      # lo que se convierte en imagen
├── theme/app_theme.dart          # colores y estilos
└── utils/captura.dart            # widget -> PNG -> compartir/guardar
```

## Ejecutar

```bash
flutter pub get
flutter run          # elige tu dispositivo o emulador
flutter test         # 13 pruebas: mensaje, autoguardado, copiado, imagen y scroll
flutter analyze
```

### Datos de ejemplo (desarrollo)

```bash
flutter run --dart-define=DEMO_SEED=true                      # formulario con datos
flutter run -t tool/demo_preview.dart --dart-define=VISTA=2    # solo la imagen
```

La carpeta `capturas/` guarda pantallas de referencia del diseño.

### Compilar

```bash
flutter build apk --release        # Android (APK para instalar/compartir)
flutter build appbundle --release  # Android (AAB para Google Play)
flutter build ios --release        # iOS
flutter build macos --release      # macOS
flutter build web --release        # Web
```

Para la firma y la publicación en Google Play, ver **[COMO_HACER_RELEASE.txt](COMO_HACER_RELEASE.txt)**.

## Compatibilidad con Android

| | |
|---|---|
| **Android mínimo** | 7.0 Nougat (API 24) |
| **Android objetivo** | 16 (API 36) — cumple los requisitos actuales de Google Play |
| **Arquitecturas** | arm64-v8a, armeabi-v7a y x86_64 |
| **Permisos** | ninguno: no usa cámara, ubicación ni almacenamiento externo |

- El mínimo de Android 7.0 lo impone el motor de Flutter y los plugins usados
  (`shared_preferences`, `path_provider`, `share_plus`, `url_launcher`), que
  requieren API 24 o superior.
- Probado con el **APK release** en Android 7.0 (API 24) y Android 16 (API 36):
  formulario, escritura, copiado al portapapeles, generación de la imagen y
  hoja de compartir funcionando en ambos.
- La app no pide permisos: la imagen se guarda en su propia carpeta
  (`Android/data/com.entreturno.entrega_turno/files/Download/Entregas de turno`).
