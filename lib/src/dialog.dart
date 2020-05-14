// Copyright (c) 2020, David PHAM-VAN <dev.nfet.net@gmail.com>
// All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';

import 'service/base.dart';
import 'service/cache.dart';
import 'service/pref_service.dart';
import 'service/shared_preferences.dart';

class PreferenceDialog extends StatefulWidget {
  const PreferenceDialog(
    this.preferences, {
    this.title,
    this.submitText,
    this.onlySaveOnSubmit = false,
    this.cancelText,
  });

  final String title;
  final List<Widget> preferences;
  final String submitText;
  final String cancelText;

  final bool onlySaveOnSubmit;

  @override
  PreferenceDialogState createState() => PreferenceDialogState();
}

class PreferenceDialogState extends State<PreferenceDialog> {
  Widget _buildDialog(BuildContext context, BasePrefService parent) {
    final actions = <Widget>[];

    if (widget.cancelText != null && widget.onlySaveOnSubmit) {
      actions.add(
        FlatButton(
          child: Text(widget.cancelText),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      );
    }

    if (widget.submitText != null) {
      actions.add(
        FlatButton(
          child: Text(widget.submitText),
          onPressed: () {
            if (widget.onlySaveOnSubmit) {
              parent.apply(PrefService.of(context));
            }
            Navigator.of(context).pop();
          },
        ),
      );
    }

    return AlertDialog(
      title: widget.title == null ? null : Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          children: widget.preferences,
        ),
      ),
      actions: actions,
    );
  }

  Future<BasePrefService> _createCache(BasePrefService parent) async {
    final service = JustCachePrefService();
    await service.apply(parent);
    return service;
  }

  Widget _buildService(BuildContext context, BasePrefService parent) {
    if (widget.onlySaveOnSubmit) {
      return FutureBuilder(
        future: _createCache(parent),
        builder: (BuildContext context, snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox();
          }

          return PrefService(
            service: snapshot.data,
            child: Builder(
              builder: (BuildContext context) => _buildDialog(context, parent),
            ),
          );
        },
      );
    }

    return _buildDialog(context, parent);
  }

  @override
  Widget build(BuildContext context) {
    // Check if we already have a BasePrefService
    final service = PrefService.of(context);
    if (service != null) {
      return _buildService(context, service);
    }

    // Fallback to SharedPreferences
    return FutureBuilder(
      future: SharedPrefService.init(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox();
        }

        return PrefService(
          service: service,
          child: Builder(builder: (BuildContext context) {
            return _buildService(context, service);
          }),
        );
      },
    );
  }
}