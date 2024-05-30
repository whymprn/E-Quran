import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_quran/globals.dart';
import 'package:my_quran/models/doa.dart';
import 'package:my_quran/screens/detail_screen.dart';

class DoaTab extends StatelessWidget {
  const DoaTab({super.key});

  Future<List<Doa>> _getDoaList() async {
    String data = await rootBundle.loadString('assets/datas/list-doa.json');
    return doaFromJson(data);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Doa>>(
        future: _getDoaList(),
        initialData: [],
        builder: ((context, snapshot) {
          if (!snapshot.hasData) {
            return Container();
          }
          return ListView.separated(
              itemBuilder: (context, index) => _doaItem(
                  context: context, doa: snapshot.data!.elementAt(index)),
              separatorBuilder: (context, index) =>
                  Divider(color: const Color(0xFF7B80AD).withOpacity(.35)),
              itemCount: snapshot.data!.length);
        }));
  }

  Widget _doaItem({required Doa doa, required BuildContext context}) =>
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => DoaScreen(
                    id: doa.id,
                  )));
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              Stack(
                children: [
                  SvgPicture.asset('assets/svgs/nomor-surah.svg'),
                  SizedBox(
                    height: 36,
                    width: 36,
                    child: Center(
                        child: Text(
                      "${doa.id}",
                      style: GoogleFonts.poppins(
                          color: Colors.white, fontWeight: FontWeight.w500),
                    )),
                  )
                ],
              ),
              const SizedBox(
                width: 16,
              ),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doa.nama,
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 16),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                ],
              )),
            ],
          ),
        ),
      );
}
