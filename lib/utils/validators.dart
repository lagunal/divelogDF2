class Validators {
  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo requerido';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Correo electrónico requerido';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Ingresa un correo electrónico válido';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Contraseña requerida';
    }
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    return null;
  }

  static String? number(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Allow empty if not combined with required
    }
    if (double.tryParse(value) == null) {
      return 'Ingresa un número válido';
    }
    return null;
  }

  static String? depth(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final depth = double.tryParse(value);
    if (depth == null) return 'Ingresa una profundidad válida';
    if (depth < 0) return 'La profundidad no puede ser negativa';
    if (depth > 300) return 'Profundidad excede límites normales'; // Warning-like validation
    return null;
  }

  static String? temperature(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final temp = double.tryParse(value);
    if (temp == null) return 'Ingresa una temperatura válida';
    if (temp < -2 || temp > 50) return 'Temperatura fuera de rango normal';
    return null;
  }
}
