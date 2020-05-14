// Copyright (c) 2020, David PHAM-VAN <dev.nfet.net@gmail.com>
// All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';

import 'service/pref_service.dart';

class CheckboxPreference extends StatefulWidget {
  const CheckboxPreference(this.title, this.localKey,
      {this.desc,
      this.defaultVal = false,
      this.ignoreTileTap = false,
      this.resetOnException = true,
      this.onEnable,
      this.onDisable,
      this.onChange,
      this.disabled = false});

  final String title;
  final String desc;
  final String localKey;
  final bool defaultVal;
  final bool ignoreTileTap;

  final bool disabled;

  final bool resetOnException;

  final Function onEnable;
  final Function onDisable;
  final Function onChange;

  @override
  _CheckboxPreferenceState createState() => _CheckboxPreferenceState();
}

class _CheckboxPreferenceState extends State<CheckboxPreference> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final service = PrefService.of(context);
    if (service.getBool(widget.localKey) == null) {
      service.setBool(widget.localKey, widget.defaultVal);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.title),
      subtitle: widget.desc == null ? null : Text(widget.desc),
      trailing: Checkbox(
        value: PrefService.of(context).getBool(widget.localKey) ??
            widget.defaultVal,
        onChanged:
            widget.disabled ? null : (val) => val ? onEnable() : onDisable(),
      ),
      onTap: (widget.ignoreTileTap || widget.disabled)
          ? null
          : () => (PrefService.of(context).getBool(widget.localKey) ??
                  widget.defaultVal)
              ? onDisable()
              : onEnable(),
    );
  }

  Future<void> onEnable() async {
    setState(() {
      PrefService.of(context).setBool(widget.localKey, true);
    });
    if (widget.onChange != null) {
      widget.onChange();
    }
    if (widget.onEnable != null) {
      try {
        await widget.onEnable();
      } catch (e) {
        if (widget.resetOnException) {
          PrefService.of(context).setBool(widget.localKey, false);
          if (mounted) {
            setState(() {});
          }
        }
        if (mounted) {
          PrefService.showError(context, e.message);
        }
      }
    }
  }

  Future<void> onDisable() async {
    setState(() {
      PrefService.of(context).setBool(widget.localKey, false);
    });
    if (widget.onChange != null) {
      widget.onChange();
    }
    if (widget.onDisable != null) {
      try {
        await widget.onDisable();
      } catch (e) {
        if (widget.resetOnException) {
          PrefService.of(context).setBool(widget.localKey, true);
          if (mounted) {
            setState(() {});
          }
        }
        if (mounted) {
          PrefService.showError(context, e.message);
        }
      }
    }
  }
}