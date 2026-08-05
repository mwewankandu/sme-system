import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../models/product.dart';
import '../inventory_provider.dart';

class ProductFormDialog extends ConsumerStatefulWidget {
  final Product? product; // null = add mode, non-null = edit mode

  const ProductFormDialog({super.key, this.product});

  @override
  ConsumerState<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends ConsumerState<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _categoryController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;
  late final TextEditingController _thresholdController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameController = TextEditingController(text: p?.name ?? '');
    _categoryController = TextEditingController(text: p?.category ?? '');
    _priceController =
        TextEditingController(text: p != null ? p.price.toString() : '');
    _stockController = TextEditingController(
        text: p != null ? p.stockQuantity.toString() : '');
    _thresholdController = TextEditingController(
        text: p != null ? p.lowStockThreshold.toString() : '5');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _thresholdController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final notifier = ref.read(inventoryNotifierProvider.notifier);
    final product = Product(
      id: widget.product?.id ?? const Uuid().v4(),
      name: _nameController.text.trim(),
      category: _categoryController.text.trim(),
      price: double.parse(_priceController.text.trim()),
      stockQuantity: int.parse(_stockController.text.trim()),
      lowStockThreshold: int.parse(_thresholdController.text.trim()),
      createdAt: widget.product?.createdAt ?? DateTime.now(),
    );

    try {
      if (widget.product == null) {
        await notifier.addProduct(product);
      } else {
        await notifier.updateProduct(product);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;
    return AlertDialog(
      title: Text(isEdit ? 'Edit Product' : 'Add Product'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _field(_nameController, 'Product Name', isRequired: true),
              const SizedBox(height: 12),
              _field(_categoryController, 'Category', isRequired: true),
              const SizedBox(height: 12),
              _field(_priceController, 'Price (ZMW)',
                  isRequired: true, isNumber: true),
              const SizedBox(height: 12),
              _field(_stockController, 'Stock Quantity',
                  isRequired: true, isNumber: true, isInt: true),
              const SizedBox(height: 12),
              _field(_thresholdController, 'Low Stock Alert At',
                  isRequired: true, isNumber: true, isInt: true),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _save,
          child: _isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : Text(isEdit ? 'Update' : 'Add'),
        ),
      ],
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    bool isRequired = false,
    bool isNumber = false,
    bool isInt = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      validator: (value) {
        if (isRequired && (value == null || value.trim().isEmpty)) {
          return '$label is required';
        }
        if (isNumber && value != null && value.isNotEmpty) {
          final parsed = isInt ? int.tryParse(value) : double.tryParse(value);
          if (parsed == null) return 'Enter a valid number';
        }
        return null;
      },
    );
  }
}