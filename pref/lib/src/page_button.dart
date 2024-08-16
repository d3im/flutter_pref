// Copyright (c) 2020, David PHAM-VAN <dev.nfet.net@gmail.com>
// All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import 'chevron.dart';
import 'disabler.dart';
import 'page.dart';

class PrefPageButton extends StatelessWidget {
  const PrefPageButton({
    super.key,
    this.title,
    required this.page,
    this.subtitle,
    this.pageTitle,
    this.leading,
    this.trailing,
    this.leadingAppBar,
    this.ownPage,
  });

  final Widget? title;
  final Widget? pageTitle;
  final Widget? subtitle;
  final PrefPage? page;
  final Widget? leading;
  final Widget? trailing;
  final Widget? leadingAppBar;
  final Function()? ownPage;

  @override
  Widget build(BuildContext context) {
    final disabled = PrefDisableState.of(context)?.disabled ?? false;

    return PrefChevron(
      onTap: disabled
          ? null
          : () => Navigator.of(context).push<void>(
                MaterialPageRoute(
                  builder: (context) => ownPage == null ? Scaffold(
                    appBar: AppBar(
                      title: pageTitle ?? title,
                      leading: leadingAppBar,
                    ),
                    body: page,
                  ) : ownPage(
                      title: pageTitle ?? title,
                      leading: leadingAppBar,
                      body: page,
                      ),
                ),
              ),
      title: title,
      subtitle: subtitle,
      leading: leading,
      trailing: trailing,
    );
  }
}
