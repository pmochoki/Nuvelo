import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/theme.dart';

/// Maps selected category to extra `categoryFields` for create listing API.
typedef CategoryExtrasCallback = void Function(Map<String, dynamic> fields);

bool _isDefaultExtrasCategory(String? id) {
  if (id == null) return false;
  const ids = {
    'electronics',
    'furniture',
    'fashion',
    'goods',
    'babies-kids',
    'services',
    'other',
  };
  return ids.contains(id);
}

/// Category-specific Step 1 fields (merged into listing `categoryFields`).
class PostCategoryFieldsSection extends StatefulWidget {
  const PostCategoryFieldsSection({
    super.key,
    required this.categoryId,
    required this.availabilityDate,
    required this.onAvailabilityDateChanged,
    required this.onExtrasChanged,
  });

  final String? categoryId;
  final DateTime availabilityDate;
  final ValueChanged<DateTime> onAvailabilityDateChanged;
  final CategoryExtrasCallback onExtrasChanged;

  @override
  State<PostCategoryFieldsSection> createState() =>
      _PostCategoryFieldsSectionState();
}

class _PostCategoryFieldsSectionState extends State<PostCategoryFieldsSection> {
  // Rentals
  String _rentalPropertyType = 'apartment';
  int _rentalBedrooms = 1;
  int _rentalBathrooms = 1;
  final _rentalArea = TextEditingController();
  bool _rentalFurnished = false;
  bool _rentalBills = false;
  bool _rentalPets = false;
  bool _rentalParking = false;

  // Vehicles
  final _vehicleMake = TextEditingController();
  final _vehicleModel = TextEditingController();
  final _vehicleYear = TextEditingController();
  final _vehicleMileage = TextEditingController();
  final _vehicleColor = TextEditingController();
  String _fuelType = 'petrol';
  String _transmission = 'manual';

  // Jobs
  String _jobType = 'full-time';
  final _jobCompany = TextEditingController();
  final _jobSalary = TextEditingController();
  String _jobExperience = 'any';

  // Events
  DateTime _eventDate = DateTime.now();
  TimeOfDay _eventTime = const TimeOfDay(hour: 18, minute: 0);
  final _eventDuration = TextEditingController();
  final _eventVenue = TextEditingController();
  bool _eventPaid = false;
  final _eventPrice = TextEditingController();
  final _eventMaxAttendees = TextEditingController();

  // Donations
  String _donationCondition = 'good';
  String _donationCollection = 'pickup';
  final _donationRadius = TextEditingController();

  // Default bucket
  String _defaultPresentationCondition = 'good';
  final _defaultBrand = TextEditingController();
  int _defaultQty = 1;

  String? _lastCategoryId;

  @override
  void initState() {
    super.initState();
    _scheduleEmit();
  }

  @override
  void dispose() {
    _rentalArea.dispose();
    _vehicleMake.dispose();
    _vehicleModel.dispose();
    _vehicleYear.dispose();
    _vehicleMileage.dispose();
    _vehicleColor.dispose();
    _jobCompany.dispose();
    _jobSalary.dispose();
    _eventDuration.dispose();
    _eventVenue.dispose();
    _eventPrice.dispose();
    _eventMaxAttendees.dispose();
    _donationRadius.dispose();
    _defaultBrand.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(PostCategoryFieldsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.categoryId != oldWidget.categoryId ||
        widget.availabilityDate != oldWidget.availabilityDate) {
      _scheduleEmit();
    }
  }

  void _scheduleEmit() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _emit());
  }

  void _emit() {
    final id = widget.categoryId;
    final map = <String, dynamic>{};
    switch (id) {
      case 'rentals':
        map.addAll({
          'propertyType': _rentalPropertyType,
          'bedrooms': _rentalBedrooms,
          'bathrooms': _rentalBathrooms,
          'areaSqm': double.tryParse(_rentalArea.text.trim().replaceAll(',', '.')),
          'furnished': _rentalFurnished,
          'billsIncluded': _rentalBills,
          'petsAllowed': _rentalPets,
          'parkingAvailable': _rentalParking,
        });
        break;
      case 'vehicles':
        map.addAll({
          'vehicleMake': _vehicleMake.text.trim(),
          'vehicleModel': _vehicleModel.text.trim(),
          'vehicleYear': int.tryParse(_vehicleYear.text.trim()),
          'mileageKm': double.tryParse(_vehicleMileage.text.trim().replaceAll(',', '')),
          'fuelType': _fuelType,
          'transmission': _transmission,
          'vehicleColor': _vehicleColor.text.trim(),
        });
        break;
      case 'jobs':
        map.addAll({
          'jobType': _jobType,
          'companyName': _jobCompany.text.trim(),
          'salaryDescription': _jobSalary.text.trim(),
          'experienceRequired': _jobExperience,
        });
        break;
      case 'events':
        map.addAll({
          'eventDate': _eventDate.toIso8601String().split('T').first,
          'eventTimeMinutes': _eventTime.hour * 60 + _eventTime.minute,
          'durationDescription': _eventDuration.text.trim(),
          'venueAddress': _eventVenue.text.trim(),
          'eventIsPaid': _eventPaid,
          'eventPriceHuf': _eventPaid
              ? double.tryParse(_eventPrice.text.trim().replaceAll(',', ''))
              : null,
          'maxAttendees': int.tryParse(_eventMaxAttendees.text.trim()),
        });
        break;
      case 'donations':
        map.addAll({
          'donationCondition': _donationCondition,
          'collectionOption': _donationCollection,
          'deliveryRadiusKm':
              _donationCollection != 'pickup'
                  ? double.tryParse(_donationRadius.text.trim().replaceAll(',', '.'))
                  : null,
        });
        break;
      default:
        if (_isDefaultExtrasCategory(id)) {
          map.addAll({
            'presentationCondition': _defaultPresentationCondition,
            'brandOptional': _defaultBrand.text.trim(),
            'quantity': _defaultQty,
          });
        }
    }
    widget.onExtrasChanged(map);
  }

  Future<void> _pickAvailabilityCupertino(BuildContext context) async {
    var picked = widget.availabilityDate;
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (ctx) => Container(
        height: 280,
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
        color: NuveloColors.cardBg,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                CupertinoButton(
                  onPressed: () {
                    widget.onAvailabilityDateChanged(picked);
                    Navigator.pop(ctx);
                    _emit();
                  },
                  child: const Text('Done'),
                ),
              ],
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: picked,
                minimumDate: DateTime.now().subtract(const Duration(days: 365)),
                maximumDate: DateTime.now().add(const Duration(days: 365 * 3)),
                onDateTimeChanged: (d) => picked = d,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAvailabilityMaterial(BuildContext context) async {
    final d = await showDatePicker(
      context: context,
      initialDate: widget.availabilityDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (d != null) {
      widget.onAvailabilityDateChanged(d);
      _emit();
    }
  }

  Future<void> _pickEventDate(BuildContext context) async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      var picked = _eventDate;
      await showCupertinoModalPopup<void>(
        context: context,
        builder: (ctx) => Container(
          height: 260,
          padding:
              EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
          color: NuveloColors.cardBg,
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: CupertinoButton(
                  onPressed: () {
                    setState(() => _eventDate = picked);
                    Navigator.pop(ctx);
                    _emit();
                  },
                  child: const Text('Done'),
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: picked,
                  minimumDate: DateTime.now().subtract(const Duration(days: 1)),
                  maximumDate: DateTime.now().add(const Duration(days: 365 * 3)),
                  onDateTimeChanged: (v) => picked = v,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      final d = await showDatePicker(
        context: context,
        initialDate: _eventDate,
        firstDate: DateTime.now().subtract(const Duration(days: 1)),
        lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
      );
      if (d != null) {
        setState(() => _eventDate = d);
        _emit();
      }
    }
  }

  Future<void> _pickEventTime(BuildContext context) async {
    final t = await showTimePicker(
      context: context,
      initialTime: _eventTime,
    );
    if (t != null) {
      setState(() => _eventTime = t);
      _emit();
    }
  }

  Widget _stepper({
    required String label,
    required int value,
    required int min,
    required int max,
    required ValueChanged<int> onChanged,
  }) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        IconButton(
          onPressed: value > min ? () => onChanged(value - 1) : null,
          icon: const Icon(Icons.remove_circle_outline),
        ),
        Text('$value'),
        IconButton(
          onPressed: value < max ? () => onChanged(value + 1) : null,
          icon: const Icon(Icons.add_circle_outline),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final id = widget.categoryId;

    if (id != _lastCategoryId) {
      _lastCategoryId = id;
      _scheduleEmit();
    }

    final children = <Widget>[];

    switch (id) {
      case 'rentals':
        children.addAll([
          Text('Rentals', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _rentalPropertyType,
            decoration: const InputDecoration(labelText: 'Property type'),
            items: const [
              DropdownMenuItem(value: 'apartment', child: Text('Apartment')),
              DropdownMenuItem(value: 'room', child: Text('Room')),
              DropdownMenuItem(value: 'house', child: Text('House')),
              DropdownMenuItem(value: 'studio', child: Text('Studio')),
              DropdownMenuItem(value: 'office', child: Text('Office')),
              DropdownMenuItem(value: 'other', child: Text('Other')),
            ],
            onChanged: (v) {
              setState(() => _rentalPropertyType = v ?? _rentalPropertyType);
              _emit();
            },
          ),
          _stepper(
            label: 'Bedrooms',
            value: _rentalBedrooms,
            min: 0,
            max: 10,
            onChanged: (v) {
              setState(() => _rentalBedrooms = v);
              _emit();
            },
          ),
          _stepper(
            label: 'Bathrooms',
            value: _rentalBathrooms,
            min: 0,
            max: 5,
            onChanged: (v) {
              setState(() => _rentalBathrooms = v);
              _emit();
            },
          ),
          TextField(
            controller: _rentalArea,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Area (m²)'),
            onChanged: (_) => _emit(),
          ),
          SwitchListTile(
            title: const Text('Furnished'),
            value: _rentalFurnished,
            onChanged: (v) {
              setState(() => _rentalFurnished = v);
              _emit();
            },
          ),
          SwitchListTile(
            title: const Text('Bills included'),
            value: _rentalBills,
            onChanged: (v) {
              setState(() => _rentalBills = v);
              _emit();
            },
          ),
          SwitchListTile(
            title: const Text('Pets allowed'),
            value: _rentalPets,
            onChanged: (v) {
              setState(() => _rentalPets = v);
              _emit();
            },
          ),
          SwitchListTile(
            title: const Text('Parking available'),
            value: _rentalParking,
            onChanged: (v) {
              setState(() => _rentalParking = v);
              _emit();
            },
          ),
          ListTile(
            title: const Text('Available from'),
            subtitle: Text(
              MaterialLocalizations.of(context).formatFullDate(
                widget.availabilityDate,
              ),
            ),
            trailing: const Icon(Icons.calendar_today_outlined),
            onTap: () async {
              if (defaultTargetPlatform == TargetPlatform.iOS) {
                await _pickAvailabilityCupertino(context);
              } else {
                await _pickAvailabilityMaterial(context);
              }
            },
          ),
        ]);
        break;
      case 'vehicles':
        children.addAll([
          Text('Vehicle', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          TextField(
            controller: _vehicleMake,
            decoration: const InputDecoration(labelText: 'Make'),
            onChanged: (_) => _emit(),
          ),
          TextField(
            controller: _vehicleModel,
            decoration: const InputDecoration(labelText: 'Model'),
            onChanged: (_) => _emit(),
          ),
          TextField(
            controller: _vehicleYear,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Year'),
            onChanged: (_) => _emit(),
          ),
          TextField(
            controller: _vehicleMileage,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Mileage (km)'),
            onChanged: (_) => _emit(),
          ),
          DropdownButtonFormField<String>(
            initialValue: _fuelType,
            decoration: const InputDecoration(labelText: 'Fuel type'),
            items: const [
              DropdownMenuItem(value: 'petrol', child: Text('Petrol')),
              DropdownMenuItem(value: 'diesel', child: Text('Diesel')),
              DropdownMenuItem(value: 'electric', child: Text('Electric')),
              DropdownMenuItem(value: 'hybrid', child: Text('Hybrid')),
              DropdownMenuItem(value: 'lpg', child: Text('LPG')),
            ],
            onChanged: (v) {
              setState(() => _fuelType = v ?? _fuelType);
              _emit();
            },
          ),
          DropdownButtonFormField<String>(
            initialValue: _transmission,
            decoration: const InputDecoration(labelText: 'Transmission'),
            items: const [
              DropdownMenuItem(value: 'manual', child: Text('Manual')),
              DropdownMenuItem(value: 'automatic', child: Text('Automatic')),
            ],
            onChanged: (v) {
              setState(() => _transmission = v ?? _transmission);
              _emit();
            },
          ),
          TextField(
            controller: _vehicleColor,
            decoration: const InputDecoration(labelText: 'Color'),
            onChanged: (_) => _emit(),
          ),
        ]);
        break;
      case 'jobs':
        children.addAll([
          Text('Job', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _jobChip('full-time', 'Full-time'),
              _jobChip('part-time', 'Part-time'),
              _jobChip('freelance', 'Freelance'),
              _jobChip('internship', 'Internship'),
              _jobChip('remote', 'Remote'),
            ],
          ),
          TextField(
            controller: _jobCompany,
            decoration: const InputDecoration(labelText: 'Company name'),
            onChanged: (_) => _emit(),
          ),
          TextField(
            controller: _jobSalary,
            decoration:
                const InputDecoration(labelText: 'Salary (e.g. 400,000 HUF/month)'),
            onChanged: (_) => _emit(),
          ),
          DropdownButtonFormField<String>(
            initialValue: _jobExperience,
            decoration: const InputDecoration(labelText: 'Experience required'),
            items: const [
              DropdownMenuItem(value: 'any', child: Text('Any')),
              DropdownMenuItem(value: '1_year', child: Text('1 year')),
              DropdownMenuItem(value: '2_3_years', child: Text('2–3 years')),
              DropdownMenuItem(value: '5_plus_years', child: Text('5+ years')),
            ],
            onChanged: (v) {
              setState(() => _jobExperience = v ?? _jobExperience);
              _emit();
            },
          ),
        ]);
        break;
      case 'events':
        children.addAll([
          Text('Event', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          ListTile(
            title: const Text('Event date'),
            subtitle: Text(
              MaterialLocalizations.of(context).formatFullDate(_eventDate),
            ),
            trailing: const Icon(Icons.calendar_today_outlined),
            onTap: () => _pickEventDate(context),
          ),
          ListTile(
            title: const Text('Event time'),
            subtitle: Text(
              MaterialLocalizations.of(context).formatTimeOfDay(
                _eventTime,
                alwaysUse24HourFormat:
                    MediaQuery.alwaysUse24HourFormatOf(context),
              ),
            ),
            trailing: const Icon(Icons.schedule_outlined),
            onTap: () => _pickEventTime(context),
          ),
          TextField(
            controller: _eventDuration,
            decoration:
                const InputDecoration(labelText: 'Duration (e.g. 3 hours)'),
            onChanged: (_) => _emit(),
          ),
          TextField(
            controller: _eventVenue,
            decoration: const InputDecoration(labelText: 'Venue / address'),
            onChanged: (_) => _emit(),
          ),
          SwitchListTile(
            title: const Text('Paid event'),
            value: _eventPaid,
            onChanged: (v) {
              setState(() => _eventPaid = v);
              _emit();
            },
          ),
          if (_eventPaid)
            TextField(
              controller: _eventPrice,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Price (HUF)'),
              onChanged: (_) => _emit(),
            ),
          TextField(
            controller: _eventMaxAttendees,
            keyboardType: TextInputType.number,
            decoration:
                const InputDecoration(labelText: 'Max attendees (optional)'),
            onChanged: (_) => _emit(),
          ),
        ]);
        break;
      case 'donations':
        children.addAll([
          Text('Donation', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _donChip('new', 'New'),
              _donChip('like_new', 'Like New'),
              _donChip('good', 'Good'),
              _donChip('worn', 'Worn'),
            ],
          ),
          DropdownButtonFormField<String>(
            initialValue: _donationCollection,
            decoration: const InputDecoration(labelText: 'Collection'),
            items: const [
              DropdownMenuItem(value: 'pickup', child: Text('Pickup only')),
              DropdownMenuItem(
                  value: 'deliver_local',
                  child: Text('Can deliver locally')),
              DropdownMenuItem(
                  value: 'post_courier',
                  child: Text('Can post / courier')),
            ],
            onChanged: (v) {
              setState(() => _donationCollection = v ?? _donationCollection);
              _emit();
            },
          ),
          if (_donationCollection != 'pickup')
            TextField(
              controller: _donationRadius,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: 'Delivery radius (km)'),
              onChanged: (_) => _emit(),
            ),
        ]);
        break;
      default:
        if (_isDefaultExtrasCategory(id)) {
          children.addAll([
            Text('Details', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _condChip('brand_new', 'Brand New'),
                _condChip('like_new', 'Like New'),
                _condChip('good', 'Good'),
                _condChip('used', 'Used'),
              ],
            ),
            TextField(
              controller: _defaultBrand,
              decoration:
                  const InputDecoration(labelText: 'Brand / make (optional)'),
              onChanged: (_) => _emit(),
            ),
            _stepper(
              label: 'Quantity',
              value: _defaultQty,
              min: 1,
              max: 999,
              onChanged: (v) {
                setState(() => _defaultQty = v);
                _emit();
              },
            ),
          ]);
        }
    }

    if (children.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _jobChip(String value, String label) {
    final sel = _jobType == value;
    return FilterChip(
      label: Text(label),
      selected: sel,
      onSelected: (_) {
        setState(() => _jobType = value);
        _emit();
      },
    );
  }

  Widget _donChip(String value, String label) {
    final sel = _donationCondition == value;
    return FilterChip(
      label: Text(label),
      selected: sel,
      onSelected: (_) {
        setState(() => _donationCondition = value);
        _emit();
      },
    );
  }

  Widget _condChip(String value, String label) {
    final sel = _defaultPresentationCondition == value;
    return FilterChip(
      label: Text(label),
      selected: sel,
      onSelected: (_) {
        setState(() => _defaultPresentationCondition = value);
        _emit();
      },
    );
  }
}
