import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:my_quran/globals.dart';
import 'package:my_quran/models/ayat.dart';
import 'package:my_quran/models/doa.dart';
import 'package:my_quran/models/surah.dart';

class SurahScreen extends StatefulWidget {
  final int noSurat;
  const SurahScreen({super.key, required this.noSurat});

  @override
  _SurahScreenState createState() => _SurahScreenState();
}

class _SurahScreenState extends State<SurahScreen> {
  late AudioPlayer _audioPlayer;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<Surah> _getDetailSurah() async {
    var data = await Dio().get("https://equran.id/api/surat/${widget.noSurat}");
    return Surah.fromJson(json.decode(data.toString()));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Surah>(
        future: _getDetailSurah(),
        initialData: null,
        builder: ((context, snapshot) {
          if (!snapshot.hasData) {
            return Scaffold(
              backgroundColor: background,
            );
          }
          Surah surah = snapshot.data!;
          return Scaffold(
            backgroundColor: background,
            appBar: _appBar(context: context, surah: surah),
            body: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                SliverToBoxAdapter(
                  child: _details(surah: surah),
                )
              ],
              body: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ListView.separated(
                  itemBuilder: (context, index) => _ayatItem(
                      ayat: surah.ayat!
                          .elementAt(index + (widget.noSurat == 1 ? 1 : 0))),
                  itemCount: surah.jumlahAyat + (widget.noSurat == 1 ? -1 : 0),
                  separatorBuilder: (context, index) => Container(),
                ),
              ),
            ),
          );
        }));
  }

  Widget _ayatItem({required Ayat ayat}) => Padding(
        padding: const EdgeInsets.only(top: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                  color: gray, borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  Container(
                    width: 27,
                    height: 27,
                    decoration: BoxDecoration(
                        color: primary,
                        borderRadius: BorderRadius.circular(27 / 2)),
                    child: Center(
                        child: Text(
                      '${ayat.nomor}',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500, color: Colors.white),
                    )),
                  ),
                  const Spacer(),
                  const SizedBox(
                    width: 16,
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 24,
            ),
            Text(
              ayat.ar,
              style: GoogleFonts.amiri(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                  height: 2),
              textAlign: TextAlign.right,
            ),
            const SizedBox(
              height: 16,
            ),
            Text(
              ayat.idn,
              style: GoogleFonts.poppins(color: text, fontSize: 16),
            ),
          ],
        ),
      );

  Widget _details({required Surah surah}) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Stack(
          children: [
            Container(
              height: 320,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: [0, .6, 1],
                  colors: [
                    Color(0xFFDF98FA),
                    Color(0xFFB070FD),
                    Color(0xFF9055FF)
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Opacity(
                opacity: .2,
                child: SvgPicture.asset(
                  'assets/svgs/quran.svg',
                  width: 324 - 55,
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              child: Column(
                children: [
                  Text(
                    surah.namaLatin,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 26,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    surah.arti,
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 16),
                  ),
                  Divider(
                    color: Colors.white.withOpacity(.35),
                    thickness: 2,
                    height: 32,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        surah.tempatTurun.name,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        "${surah.jumlahAyat} Ayat",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SvgPicture.asset('assets/svgs/bismillah.svg'),
                  const SizedBox(height: 25),
                  ElevatedButton(
                    onPressed: () {
                      _toggleAudio(surah.audio);
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: const Color.fromARGB(255, 163, 4, 236),
                      backgroundColor: Colors.white,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPlaying ? Icons.pause : Icons.play_arrow_outlined,
                          color: Colors.black,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          isPlaying ? "Pause Audio" : "Putar Audio",
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      );

  void _toggleAudio(String url) async {
    if (isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play(UrlSource(url));
    }
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  AppBar _appBar({required BuildContext context, required Surah surah}) =>
      AppBar(
        backgroundColor: background,
        automaticallyImplyLeading: false,
        elevation: 0,
        title: Row(children: [
          IconButton(
              onPressed: (() => Navigator.of(context).pop()),
              icon: SvgPicture.asset('assets/svgs/back-icon.svg')),
          const SizedBox(
            width: 24,
          ),
        ]),
      );
}

// SURAH FULL ----------------------------------------------------------------------------------------------------
class SurahFullScreen extends StatefulWidget {
  final int noSurat;
  const SurahFullScreen({super.key, required this.noSurat});

  @override
  _SurahFullScreenState createState() => _SurahFullScreenState();
}

class _SurahFullScreenState extends State<SurahFullScreen> {
  late AudioPlayer _audioPlayer;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<Surah> _getDetailSurahFull() async {
    var data = await Dio().get("https://equran.id/api/surat/${widget.noSurat}");
    return Surah.fromJson(json.decode(data.toString()));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Surah>(
        future: _getDetailSurahFull(),
        initialData: null,
        builder: ((context, snapshot) {
          if (!snapshot.hasData) {
            return Scaffold(
              backgroundColor: background,
            );
          }
          Surah surah = snapshot.data!;
          return Scaffold(
            backgroundColor: background,
            appBar: _appBar(context: context, surah: surah),
            body: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                SliverToBoxAdapter(
                  child: _details(surah: surah),
                )
              ],
              body: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ListView(
                  children: [
                    _ayatItem(surah: surah),
                  ],
                ),
              ),
            ),
          );
        }));
  }

  Widget _ayatItem({required Surah surah}) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(
            height: 24,
          ),
          RichText(
            textAlign: TextAlign.justify,
            text: TextSpan(
              children: surah.ayat!.map((e) {
                return TextSpan(
                  text: '${e.ar} ',
                  style: GoogleFonts.amiri(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                    height: 2,
                  ),
                  children: [
                    TextSpan(
                      text: '(${e.nomor}) ',
                      style: GoogleFonts.amiri(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        height: 2,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          RichText(
            textAlign: TextAlign.justify,
            text: TextSpan(
              children: surah.ayat!.map((e) {
                return TextSpan(
                  text: '${e.nomor}. ${e.idn} ',
                  style: GoogleFonts.poppins(
                    color: text,
                    fontSize: 16,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _details({required Surah surah}) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Stack(
          children: [
            Container(
              height: 320,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: [0, .6, 1],
                  colors: [
                    Color(0xFFDF98FA),
                    Color(0xFFB070FD),
                    Color(0xFF9055FF)
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Opacity(
                opacity: .2,
                child: SvgPicture.asset(
                  'assets/svgs/quran.svg',
                  width: 324 - 55,
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              child: Column(
                children: [
                  Text(
                    surah.namaLatin,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 26,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    surah.arti,
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 16),
                  ),
                  Divider(
                    color: Colors.white.withOpacity(.35),
                    thickness: 2,
                    height: 32,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        surah.tempatTurun.name,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        "${surah.jumlahAyat} Ayat",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SvgPicture.asset('assets/svgs/bismillah.svg'),
                  const SizedBox(height: 25),
                  ElevatedButton(
                    onPressed: () {
                      _toggleAudio(surah.audio);
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: const Color.fromARGB(255, 163, 4, 236),
                      backgroundColor: Colors.white,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPlaying ? Icons.pause : Icons.play_arrow_outlined,
                          color: Colors.black,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          isPlaying ? "Pause Audio" : "Putar Audio",
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      );

  void _toggleAudio(String url) async {
    if (isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play(UrlSource(url));
    }
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  AppBar _appBar({required BuildContext context, required Surah surah}) =>
      AppBar(
        backgroundColor: background,
        automaticallyImplyLeading: false,
        elevation: 0,
        title: Row(children: [
          IconButton(
              onPressed: (() => Navigator.of(context).pop()),
              icon: SvgPicture.asset('assets/svgs/back-icon.svg')),
          const SizedBox(
            width: 24,
          ),
        ]),
      );
}

// DOA ----------------------------------------------------------------------------------------------------
class DoaScreen extends StatelessWidget {
  final int id;
  const DoaScreen({super.key, required this.id});

  Future<Doa> _getDetailDoa() async {
    var data = await Dio().get("https://equran.id/api/doa/$id");
    return Doa.fromJson(json.decode(data.toString()));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Doa>(
        future: _getDetailDoa(),
        initialData: null,
        builder: ((context, snapshot) {
          if (!snapshot.hasData) {
            return Scaffold(
              backgroundColor: background,
            );
          }
          Doa doa = snapshot.data!;
          return Scaffold(
            backgroundColor: background,
            appBar: _appBar(context: context, doa: doa),
            body: NestedScrollView(
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverToBoxAdapter(
                    child: _details(doa: doa),
                  ),
                ];
              },
              body: Padding(
                padding: const EdgeInsets.all(20),
                child: ListView(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      doa.ar,
                      style: GoogleFonts.amiri(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                          height: 2),
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Text(
                      doa.idn,
                      style: GoogleFonts.poppins(color: text, fontSize: 16),
                    )
                  ],
                ),
              ),
            ),
          );
        }));
  }

  Widget _details({required Doa doa}) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Stack(children: [
          Container(
            height: 350,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: [
                      0,
                      .6,
                      1
                    ],
                    colors: [
                      Color(0xFFDF98FA),
                      Color(0xFFB070FD),
                      Color(0xFF9055FF)
                    ])),
          ),
          Positioned(
              bottom: 0,
              right: 0,
              child: Opacity(
                  opacity: .2,
                  child: SvgPicture.asset(
                    'assets/svgs/quran.svg',
                    width: 324 - 55,
                  ))),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            child: Column(
              children: [
                Text(
                  doa.nama,
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 15),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  doa.grup,
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 16),
                ),
                Divider(
                  color: Colors.white.withOpacity(.35),
                  thickness: 2,
                  height: 32,
                ),
                const SizedBox(
                  height: 16,
                ),
                SvgPicture.asset('assets/svgs/bismillah.svg')
              ],
            ),
          )
        ]),
      );

  AppBar _appBar({required BuildContext context, required Doa doa}) => AppBar(
        backgroundColor: background,
        automaticallyImplyLeading: false,
        elevation: 0,
        title: Row(children: [
          IconButton(
              onPressed: (() => Navigator.of(context).pop()),
              icon: SvgPicture.asset('assets/svgs/back-icon.svg')),
          const SizedBox(
            width: 24,
          ),
        ]),
      );
}
