import 'dart:convert';

import 'package:caffinet_app_flutter/features/search/presentation/pages/search_page_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart' as latlng;

import '../../models/search_models.dart';
import 'cafe_menu_section.dart';

class CafeDetailPage extends StatefulWidget {
  final SearchResult result;
  final CafeteriaSchedule? horario;
  final List<dynamic> calificaciones;
  final GuideSelectedCallback onGuideSelected;

  /// ID del usuario actualmente logeado
  final int userId;

  const CafeDetailPage({
    super.key,
    required this.result,
    this.horario,
    this.calificaciones = const [],
    required this.onGuideSelected,
    required this.userId,
  });

  @override
  State<CafeDetailPage> createState() => _CafeDetailPageState();
}

class _CafeDetailPageState extends State<CafeDetailPage> {
  final String _baseUrl = 'http://127.0.0.1:8000';

  List<dynamic> _calificaciones = [];
  bool _loadingRatings = false;
  bool _sendingRating = false;
  String? _errorMessage;

  int? _myRating; // rating del usuario actual
  double _averageRating = 0.0;
  int _ratingCount = 0;

  @override
  void initState() {
    super.initState();

    _calificaciones = List<dynamic>.from(widget.calificaciones);
    _updateSummaryFromCalificaciones();
    _detectMyRating();
    _loadRatingsFromApi();
  }

  // ----------------- RATING HELPERS -----------------

  void _updateSummaryFromCalificaciones() {
    if (_calificaciones.isEmpty) {
      _averageRating = 0.0;
      _ratingCount = 0;
      return;
    }

    double sum = 0.0;
    int count = 0;

    for (final cal in _calificaciones) {
      if (cal is Map && cal['rating'] != null) {
        final raw = cal['rating'];
        double value;

        if (raw is num) {
          value = raw.toDouble();
        } else {
          value = double.tryParse(raw.toString()) ?? 0.0;
        }

        sum += value;
        count++;
      }
    }

    if (count == 0) {
      _averageRating = 0.0;
      _ratingCount = 0;
    } else {
      _averageRating = sum / count;
      _ratingCount = count;
    }
  }

  /// Detecta si el usuario actual ya tiene una calificación en la lista
  void _detectMyRating() {
    final userId = widget.userId;

    int? found;
    for (final cal in _calificaciones) {
      if (cal is Map && cal['usuario_id'] != null) {
        final rawUser = cal['usuario_id'];
        final int calUserId =
            rawUser is int ? rawUser : int.tryParse(rawUser.toString()) ?? -1;

        if (calUserId == userId) {
          final rawRating = cal['rating'];
          if (rawRating is num) {
            found = rawRating.toInt();
          } else {
            found = int.tryParse(rawRating.toString());
          }
          break;
        }
      }
    }

    _myRating = found;
  }

  Future<void> _loadRatingsFromApi() async {
    setState(() {
      _loadingRatings = true;
      _errorMessage = null;
    });

    try {
      final cafeId = widget.result.cafeteriaIdAsInt;
      final uri = Uri.parse('$_baseUrl/calificaciones/$cafeId');

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          if (data is List) {
            _calificaciones = data;
          } else {
            _calificaciones = [];
          }
          _updateSummaryFromCalificaciones();
          _detectMyRating(); // ver si este usuario ya calificó
        });
      } else {
        setState(() {
          _errorMessage =
              'Error al cargar calificaciones (${response.statusCode})';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar calificaciones: $e';
      });
    } finally {
      setState(() {
        _loadingRatings = false;
      });
    }
  }

  Future<void> _sendRating(int value) async {
    // Si ya tiene rating, no dejamos mandar otra reseña
    if (_myRating != null) {
      setState(() {
        _errorMessage =
            'Ya calificaste esta cafetería con $_myRating estrellas.';
      });
      return;
    }

    final int userId = widget.userId;

    setState(() {
      _sendingRating = true;
      _errorMessage = null;
      _myRating = value; // marcamos inmediatamente en UI
    });

    try {
      final cafeId = widget.result.cafeteriaIdAsInt;
      final uri = Uri.parse('$_baseUrl/calificaciones/').replace(
        queryParameters: {
          'usuario_id': userId.toString(),
          'cafeteria_id': cafeId.toString(),
          'rating': value.toString(),
        },
      );

      final response = await http.post(uri);

      if (response.statusCode != 200) {
        setState(() {
          _errorMessage =
              'Error al guardar la calificación (${response.statusCode})';
        });
      } else {
        // Recargamos para actualizar promedio y lista
        await _loadRatingsFromApi();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al guardar la calificación: $e';
      });
    } finally {
      setState(() {
        _sendingRating = false;
      });
    }
  }

  // ----------------- UI -----------------

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    final horario = widget.horario;

    final tierColor = switch (result.tier) {
      CafeTier.bronze => Colors.brown,
      CafeTier.silver => Colors.blueGrey,
      CafeTier.gold => Colors.amber,
    };

    final String? imageUrl = result.thumbnail;

    final String? openTime = horario?.horaApertura;
    final String? closeTime = horario?.horaCierre;
    final String? days = horario?.diasAbre;

    final String horarioTexto = (openTime != null && closeTime != null)
        ? '$openTime - $closeTime'
        : 'Horario no disponible';

    final bool hasValidCoords = result.latitude != 0 && result.longitude != 0;
    final latlng.LatLng cafePosition =
        latlng.LatLng(result.latitude, result.longitude);

    final bool hasAddress = result.address.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Search Result'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          // -------- Card principal ----------
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.purple.shade100,
                        backgroundImage:
                            (imageUrl != null && imageUrl.isNotEmpty)
                                ? NetworkImage(imageUrl)
                                : null,
                        child: (imageUrl == null || imageUrl.isEmpty)
                            ? const Icon(Icons.local_cafe)
                            : null,
                      ),
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: result.status == OpenStatus.open
                                ? Colors.green
                                : Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            result.status == OpenStatus.open
                                ? Icons.check
                                : Icons.close,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                result.name,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: tierColor.withOpacity(.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: tierColor),
                              ),
                              child: Text(
                                result.tier.label,
                                style: TextStyle(
                                  color: tierColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: -6,
                          children: result.tags
                              .take(3)
                              .map(
                                (t) => Chip(
                                  label: Text(
                                    t,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  padding: EdgeInsets.zero,
                                  visualDensity: VisualDensity.compact,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  side: BorderSide(
                                      color: Colors.grey.shade300),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.star,
                                size: 18, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              '${_averageRating.toStringAsFixed(1)} ($_ratingCount)',
                            ),
                            const SizedBox(width: 16),
                            const Icon(Icons.location_on_outlined, size: 18),
                            const SizedBox(width: 4),
                            Text('${result.distanceMi.toStringAsFixed(1)} mi'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // -------- Descripción ----------
          Text(
            'Description',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),

          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.place_outlined),
            title: Text(
              hasAddress
                  ? result.address
                  : hasValidCoords
                      ? 'Ubicación disponible en el mapa'
                      : 'Dirección no disponible',
            ),
            subtitle: hasValidCoords
                ? Text(
                    '${result.latitude.toStringAsFixed(5)}, '
                    '${result.longitude.toStringAsFixed(5)}',
                  )
                : null,
          ),
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.access_time),
            title: Text(horarioTexto),
          ),
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.calendar_month_outlined),
            title: Text(days ?? 'Días no disponibles'),
          ),

          const SizedBox(height: 8),

          CafeMenuSection(
            cafeteriaId: result.id,
          ),

          const SizedBox(height: 16),

          // -------- Mapa ----------
          Text('Map', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),

          if (hasValidCoords)
            SizedBox(
              height: 200,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: cafePosition,
                    initialZoom: 16,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.caffinet_app_flutter',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: cafePosition,
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.location_on,
                            size: 40,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          else
            Container(
              height: 160,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Center(
                child: Icon(Icons.map_outlined, size: 48),
              ),
            ),

          const SizedBox(height: 16),

          FilledButton(
            onPressed: () {
              widget.onGuideSelected(result.id, result.name);
              Navigator.pop(context);
            },
            child: const Text('Guide'),
          ),

          const SizedBox(height: 16),

          // -------- Calificaciones ----------
          Text('Ratings', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),

          Row(
            children: [
              const Icon(Icons.star, size: 18, color: Colors.amber),
              const SizedBox(width: 4),
              Text(
                '${_averageRating.toStringAsFixed(1)} ($_ratingCount calificaciones)',
              ),
            ],
          ),
          const SizedBox(height: 8),

          Text(
            _myRating == null
                ? 'Deja tu calificación:'
                : 'Ya calificaste esta cafetería con $_myRating estrellas.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 4),

          Row(
            children: List.generate(5, (index) {
              final starValue = index + 1;
              final bool filled =
                  _myRating != null ? starValue <= _myRating! : false;
              return IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  filled ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 28,
                ),
                onPressed: (_sendingRating || _myRating != null)
                    ? null
                    : () => _sendRating(starValue),
              );
            }),
          ),

          if (_sendingRating) ...[
            const SizedBox(height: 4),
            const Text('Guardando calificación...'),
          ],

          if (_errorMessage != null) ...[
            const SizedBox(height: 4),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ],

          const SizedBox(height: 12),

          if (_loadingRatings)
            const Center(child: CircularProgressIndicator())
          else if (_calificaciones.isEmpty)
            const Text('Aún no hay calificaciones.')
          else ..._calificaciones.map<Widget>((cal) {
            final rating = cal is Map && cal['rating'] != null
                ? cal['rating'].toString()
                : '-';
            final comment = cal is Map && cal['comment'] != null
                ? cal['comment'].toString()
                : '';
            return ListTile(
              dense: true,
              leading: const Icon(Icons.person),
              title: Text('Rating: $rating'),
              subtitle: Text(comment),
            );
          }).toList(),
        ],
      ),
    );
  }
}
