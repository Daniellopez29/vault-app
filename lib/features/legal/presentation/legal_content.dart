/// Contenido estático de los documentos legales de Vault.
///
/// Mantenerlo separado de la UI (`legal_page.dart`) para que actualizar el
/// texto no implique tocar código de presentación.
class LegalSection {
  final String heading;
  final String body;

  const LegalSection({required this.heading, required this.body});
}

class LegalDocumentContent {
  final String title;
  final String lastUpdated;
  final String intro;
  final List<LegalSection> sections;

  const LegalDocumentContent({
    required this.title,
    required this.lastUpdated,
    required this.intro,
    required this.sections,
  });
}

const kTermsOfService = LegalDocumentContent(
  title: 'Términos y Condiciones',
  lastUpdated: 'Julio 2026',
  intro:
      'Estos Términos y Condiciones regulan el uso de Vault (la "App"), una '
      'plataforma para catalogar, mostrar y comercializar activos personales '
      'de valor (calzado, relojes y artículos similares). Al crear una cuenta '
      'o usar la App aceptás los términos descritos a continuación.',
  sections: [
    LegalSection(
      heading: '1. Aceptación de los términos',
      body:
          'El uso de Vault implica la aceptación total de este documento y de '
          'la Política de Privacidad. Si no estás de acuerdo con alguna '
          'cláusula, no debés registrarte ni utilizar la App.',
    ),
    LegalSection(
      heading: '2. Cuentas y roles de usuario',
      body:
          'El registro requiere un correo electrónico y contraseña, o el '
          'inicio de sesión con tu cuenta de Google. Al crear tu cuenta '
          'elegís un rol (Usuario, Vendedor, Restaurador o Servicio), que '
          'determina qué funciones ves en la App. Sos responsable de '
          'mantener la confidencialidad de tus credenciales y de toda '
          'actividad realizada desde tu cuenta.',
    ),
    LegalSection(
      heading: '3. Registro de activos y contenido publicado',
      body:
          'Al registrar un activo (artículo, foto, descripción, condición, '
          'talla u origen) declarás que la información es verídica y que '
          'contás con los derechos necesarios sobre las imágenes y datos que '
          'subís. Vault puede remover contenido que incumpla estos términos '
          'o que sea reportado como fraudulento, ofensivo o falso.',
    ),
    LegalSection(
      heading: '4. Marketplace y transacciones entre usuarios',
      body:
          'Vault actúa como intermediario que conecta a usuarios interesados '
          'en comprar, vender o restaurar activos. La App no es parte de la '
          'transacción entre comprador y vendedor: no garantiza la '
          'autenticidad, el estado ni la entrega de los artículos '
          'publicados. Cada usuario es responsable de verificar lo que '
          'compra o vende antes de concretar un acuerdo.',
    ),
    LegalSection(
      heading: '5. Conducta esperada',
      body:
          'No está permitido: publicar artículos falsificados a sabiendas, '
          'suplantar la identidad de otra persona o negocio, usar la App '
          'para fines distintos a los descritos, ni intentar vulnerar sus '
          'medidas de seguridad (incluyendo el bloqueo de capturas de '
          'pantalla en las pantallas de autenticación).',
    ),
    LegalSection(
      heading: '6. Seguridad de la cuenta',
      body:
          'Por tu seguridad, la App bloquea las capturas y grabaciones de '
          'pantalla durante el flujo de inicio de sesión y registro, y '
          'cierra tu sesión automáticamente tras 5 minutos de inactividad. '
          'Estas medidas buscan proteger tus credenciales; podés perder '
          'trabajo no guardado si tu sesión se cierra por inactividad.',
    ),
    LegalSection(
      heading: '7. Propiedad intelectual',
      body:
          'El nombre "Vault", su logo, diseño de interfaz y código fuente '
          'pertenecen a sus desarrolladores. Las fotos y descripciones de '
          'los activos publicados por cada usuario siguen siendo de su '
          'propiedad; al publicarlas le otorgás a Vault una licencia no '
          'exclusiva para mostrarlas dentro de la App.',
    ),
    LegalSection(
      heading: '8. Eliminación de cuenta',
      body:
          'Podés eliminar tu cuenta en cualquier momento desde '
          'Configuración → Eliminar cuenta. Esta acción es irreversible: se '
          'elimina tu perfil, tus activos registrados y tu historial '
          'asociado.',
    ),
    LegalSection(
      heading: '9. Limitación de responsabilidad',
      body:
          'Vault se ofrece "tal cual". No garantizamos disponibilidad '
          'ininterrumpida ni la exactitud del contenido publicado por otros '
          'usuarios. En la medida permitida por la ley, no somos '
          'responsables por pérdidas derivadas de transacciones entre '
          'usuarios ni por el uso indebido de la plataforma.',
    ),
    LegalSection(
      heading: '10. Cambios a estos términos',
      body:
          'Podemos actualizar este documento para reflejar cambios en la '
          'App o en la normativa aplicable. Te notificaremos los cambios '
          'relevantes dentro de la propia App. El uso continuado de Vault '
          'después de una actualización implica la aceptación de la nueva '
          'versión.',
    ),
  ],
);

const kPrivacyPolicy = LegalDocumentContent(
  title: 'Política de Privacidad',
  lastUpdated: 'Julio 2026',
  intro:
      'En Vault nos tomamos en serio la privacidad de tus datos. Esta '
      'política explica qué información recopilamos, cómo la usamos y qué '
      'control tenés sobre ella.',
  sections: [
    LegalSection(
      heading: '1. Información que recopilamos',
      body:
          'Datos de cuenta: nombre completo, correo electrónico y, según tu '
          'rol, teléfono, nombre de negocio, especialidad o ubicación. Datos '
          'de contenido: los activos que registrás (fotos, marca, talla, '
          'condición) y tu actividad dentro de la App (me gusta, '
          'comentarios, favoritos, artículos en tu carrito).',
    ),
    LegalSection(
      heading: '2. Autenticación con terceros',
      body:
          'Usamos Firebase Authentication para gestionar el inicio de '
          'sesión. Si elegís "Continuar con Google", Google comparte con '
          'nosotros tu nombre, correo y foto de perfil según los permisos '
          'que autorices; no accedemos a tu contraseña de Google en ningún '
          'momento.',
    ),
    LegalSection(
      heading: '3. Cómo usamos tu información',
      body:
          'Usamos tus datos para: crear y mantener tu cuenta, mostrar tu '
          'perfil y tus activos a otros usuarios, personalizar la App según '
          'tu rol, y mejorar la experiencia general del producto. No '
          'vendemos tu información personal a terceros.',
    ),
    LegalSection(
      heading: '4. Visibilidad frente a otros usuarios',
      body:
          'Tu nombre, foto de perfil y los activos que publiques son '
          'visibles para otros usuarios de la App, ya que Vault es una '
          'plataforma social y de marketplace. Los comentarios que dejás en '
          'publicaciones son visibles públicamente junto con tu nombre.',
    ),
    LegalSection(
      heading: '5. Seguridad técnica de tus datos',
      body:
          'Tus credenciales se gestionan mediante Firebase, con conexión '
          'cifrada. Adicionalmente, la App bloquea las capturas de pantalla '
          'durante el login/registro y cierra la sesión automáticamente '
          'tras 5 minutos sin actividad, para reducir el riesgo de acceso no '
          'autorizado si dejás el dispositivo desatendido.',
    ),
    LegalSection(
      heading: '6. Retención de datos',
      body:
          'Conservamos tu información mientras tu cuenta esté activa. Si '
          'eliminás tu cuenta desde Configuración, tus datos personales y '
          'activos registrados se eliminan de forma permanente, salvo '
          'aquellos que debamos conservar por obligación legal.',
    ),
    LegalSection(
      heading: '7. Tus derechos',
      body:
          'Podés acceder y editar tu nombre y contraseña desde '
          'Configuración en cualquier momento, y eliminar tu cuenta (y con '
          'ella, tus datos personales) cuando lo desees. Si tenés dudas '
          'sobre el tratamiento de tus datos, podés contactarnos por los '
          'medios indicados al final de este documento.',
    ),
    LegalSection(
      heading: '8. Menores de edad',
      body:
          'Vault no está dirigido a menores de 13 años. Si tenés entre 13 y '
          '18 años, necesitás el consentimiento de tu tutor legal para usar '
          'la App, en particular para participar del marketplace.',
    ),
    LegalSection(
      heading: '9. Cambios a esta política',
      body:
          'Si modificamos esta política de forma relevante, te lo '
          'notificaremos dentro de la App antes de que el cambio entre en '
          'vigencia.',
    ),
    LegalSection(
      heading: '10. Contacto',
      body:
          'Ante cualquier consulta sobre privacidad o tus datos personales, '
          'podés escribirnos desde la sección de soporte en Configuración.',
    ),
  ],
);
