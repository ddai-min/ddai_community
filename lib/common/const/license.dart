class LicenseItem {
  final String title;
  final String url;
  final String copyright;
  final String license;

  LicenseItem({
    required this.title,
    required this.url,
    required this.copyright,
    required this.license,
  });
}

class LicenseDescriptionItem {
  final String title;
  final String description;

  LicenseDescriptionItem({
    required this.title,
    required this.description,
  });
}

List<LicenseItem> license = [
  LicenseItem(
    title: 'cupertino_icons',
    url: 'https://pub.dev/packages/cupertino_icons',
    copyright: 'Copyright (c) 2016 Vladimir Kharlampidi',
    license: 'MIT',
  ),
  LicenseItem(
    title: 'go_router',
    url: 'https://pub.dev/packages/go_router',
    copyright: 'Copyright 2013 The Flutter Authors. All rights reserved.',
    license: 'BSD-3-Clause',
  ),
  LicenseItem(
    title: 'json_annotation',
    url: 'https://pub.dev/packages/json_annotation',
    copyright: 'Copyright 2017, the Dart project authors. All rights reserved.',
    license: 'BSD-3-Clause',
  ),
  LicenseItem(
    title: 'firebase_core',
    url: 'https://pub.dev/packages/firebase_core',
    copyright: 'Copyright 2017 The Chromium Authors. All rights reserved.',
    license: 'BSD-3-Clause',
  ),
  LicenseItem(
    title: 'firebase_auth',
    url: 'https://pub.dev/packages/firebase_auth',
    copyright: 'Copyright 2017 The Chromium Authors. All rights reserved.',
    license: 'BSD-3-Clause',
  ),
  LicenseItem(
    title: 'cloud_firestore',
    url: 'https://pub.dev/packages/cloud_firestore',
    copyright:
        'Copyright 2017, the Chromium project authors. All rights reserved.',
    license: 'BSD-3-Clause',
  ),
  LicenseItem(
    title: 'logger',
    url: 'https://pub.dev/packages/logger',
    copyright:
        'Copyright (c) 2019 Simon Leier, Copyright (c) 2019 Harm Aarts, Copyright (c) 2023 Severin Hamader',
    license: 'MIT',
  ),
  LicenseItem(
    title: 'flutter_riverpod',
    url: 'https://pub.dev/packages/flutter_riverpod',
    copyright: 'Copyright (c) 2020 Remi Rousselet',
    license: 'MIT',
  ),
  LicenseItem(
    title: 'flutter_dotenv',
    url: 'https://pub.dev/packages/flutter_dotenv',
    copyright: 'Copyright (c) 2018 java-james',
    license: 'MIT',
  ),
];

List<LicenseDescriptionItem> licenseDescription = [
  LicenseDescriptionItem(
    title: 'MIT',
    description: mitDescription,
  ),
  LicenseDescriptionItem(
    title: 'BSD-3-Clause',
    description: bsd3Description,
  ),
];

const mitDescription = '''
The MIT License (MIT)

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
''';

const bsd3Description = '''
Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above
      copyright notice, this list of conditions and the following
      disclaimer in the documentation and/or other materials provided
      with the distribution.
    * Neither the name of Google Inc. nor the names of its
      contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
''';
