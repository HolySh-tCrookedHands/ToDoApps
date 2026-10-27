import 'package:flutter/material.dart';

import 'package:ToDo/models/settings.dart';

class SettingsScreen extends StatelessWidget {
  final AppSettings settings;

  const SettingsScreen({
    super.key,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settings,

      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Настройки'),
            centerTitle: true,
          ),

          body: Padding(
            padding: const EdgeInsets.all(16),

            child: Column(
              children: [
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,

                  children: [
                    const Text('Основной цвет'),

                    DropdownButton<String>(
                      value: settings.selectedColor,

                      onChanged: (String? value) {
                        if (value == null) return;

                        settings.setColor(value);
                      },

                      items:
                          AppSettings.colors.entries.map(
                        (entry) {
                          return DropdownMenuItem<String>(
                            value: entry.key,

                            child: Row(
                              children: [
                                Container(
                                  width: 18,
                                  height: 18,

                                  decoration: BoxDecoration(
                                    color: entry.value,
                                    shape: BoxShape.circle,

                                    border: Border.all(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 8),

                                Text(entry.key),
                              ],
                            ),
                          );
                        },
                      ).toList(),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,

                  children: [
                    const Text('Шрифт'),

                    DropdownButton<String>(
                      value: settings.selectedFont,

                      onChanged: (String? value) {
                        if (value == null) return;

                        settings.setFont(value);
                      },

                      items:
                          AppSettings.fonts.map(
                        (font) {
                          return DropdownMenuItem<String>(
                            value: font,

                            child: Text(
                              font,
                              style: TextStyle(
                                fontFamily: font,
                              ),
                            ),
                          );
                        },
                      ).toList(),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,

                  children: [
                    const Text('Размер шрифта'),

                    DropdownButton<double>(
                      value: settings.selectedFontSize,

                      onChanged: (double? value) {
                        if (value == null) return;

                        settings.setFontSize(value);
                      },

                      items:
                          AppSettings.fontSizes.map(
                        (size) {
                          return DropdownMenuItem<double>(
                            value: size,

                            child: Text(
                              '${size.toInt()} px',
                            ),
                          );
                        },
                      ).toList(),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,

                  children: [
                    const Text('Тёмная тема'),

                    Switch(
                      value: settings.isDarkMode,

                      onChanged: (bool value) {
                        settings.setDarkMode(value);
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                Text(
                  'Пример текста',

                  style: TextStyle(
                    color: settings.color,
                    fontFamily:
                        settings.selectedFont,
                    fontSize:
                        settings.selectedFontSize,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
