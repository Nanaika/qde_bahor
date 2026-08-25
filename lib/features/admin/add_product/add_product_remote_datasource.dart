import 'dart:async';
import 'dart:js_interop';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:qde_eco_bahor/features/admin/models/product_model.dart';

import 'dart:convert';
import 'package:web/web.dart' as web;

import '../../../core/utils/app_constants.dart';

abstract class AddProductRemoteDataSource {
  Future add(
    ProductModel item,
    Uint8List imageBytes,
  );
}

class AddProductRemoteDataSourceImpl implements AddProductRemoteDataSource {
  final db = FirebaseFirestore.instance;

  @override
  Future<void> add(
    ProductModel item,
    Uint8List imageBytes,
  ) async {
    final docRef = db.collection(AppConstants.products).doc();

    // final compressedBytes = await compute(
    //   _compressInIsolate,
    //   _CompressParams(imageBytes, 1024, 75),
    // );
    final compressedBytes = await compressImageWeb(imageBytes);

    final String? imageUrl = await _uploadProductImage(
      docId: docRef.id,
      imageBytes: compressedBytes,
    );

    if (imageUrl == null) {
      throw Exception('Cant load image');
    }

    final updatedItem = item.copyWith(id: docRef.id, photoUrl: imageUrl);

    await docRef.set({
      ...updatedItem.toJson(),
      'date': FieldValue.serverTimestamp(), // Точное время сервера Firestore
    });
  }
}

Future<String?> _uploadProductImage({
  required String docId,
  required Uint8List imageBytes,
}) async {
  try {
    // Сохраняем в папку products_images/<docId>.jpg
    final storageRef = FirebaseStorage.instance.ref().child(AppConstants.productsImages).child('$docId.jpg');

    // Метаданные для правильного отображения картинки в браузере
    final metadata = SettableMetadata(
      contentType: 'image/jpeg',
    );

    final uploadTask = await storageRef.putData(imageBytes, metadata);

    // Получаем постоянную публичную ссылку
    final downloadUrl = await uploadTask.ref.getDownloadURL();
    return downloadUrl;
  } catch (e) {
    print('Ошибка загрузки изображения в Storage: $e');
    return null;
  }
}

class _CompressParams {
  final Uint8List bytes;
  final int maxWidth;
  final int quality;

  _CompressParams(this.bytes, this.maxWidth, this.quality);
}

Future<Uint8List> compressImageWeb(
  Uint8List bytes, {
  int maxWidth = 1024,
  double quality = 0.75,
}) async {
  final completer = Completer<Uint8List>();

  // 1. Создаем Blob и URL из входящих байтов
  final arrayBuffer = bytes.buffer.toJS;
  final blob = web.Blob([arrayBuffer].toJS);
  final url = web.URL.createObjectURL(blob);

  // 2. Создаем HTMLImageElement
  final img = web.HTMLImageElement();

  img.onLoad.listen((_) {
    int width = img.naturalWidth;
    int height = img.naturalHeight;

    if (width > maxWidth) {
      height = ((maxWidth / width) * height).round();
      width = maxWidth;
    }

    // 3. Создаем Canvas и рендерим сжатый кадр
    final canvas = web.document.createElement('canvas') as web.HTMLCanvasElement;
    canvas.width = width;
    canvas.height = height;

    final ctx = canvas.getContext('2d') as web.CanvasRenderingContext2D;
    ctx.drawImage(img, 0, 0, width.toDouble(), height.toDouble());

    // 4. Получаем dataURL и переводим в Uint8List
    final dataUrl = canvas.toDataURL('image/jpeg', quality.toJS);
    final base64String = dataUrl.split(',').last;

    web.URL.revokeObjectURL(url);
    completer.complete(base64Decode(base64String));
  });

  img.onError.listen((_) {
    web.URL.revokeObjectURL(url);
    completer.complete(bytes); // При сбое возвращаем оригинальные байты
  });

  img.src = url;
  return completer.future;
}
