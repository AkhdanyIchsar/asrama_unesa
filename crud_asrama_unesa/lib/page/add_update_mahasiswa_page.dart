import 'dart:convert';
import 'dart:io';

import 'package:crud_mysql_mahasiswa/api_mahasiswa.dart';
import 'package:crud_mysql_mahasiswa/model/mahasiswa.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class AddUpdateMahasiswaPage extends StatefulWidget {
  final String type;
  final Mahasiswa? mahasiswa;

  const AddUpdateMahasiswaPage({Key? key, required this.type, this.mahasiswa})
      : super(key: key);
  @override
  _AddUpdateMahasiswaPageState createState() => _AddUpdateMahasiswaPageState();
}

class _AddUpdateMahasiswaPageState extends State<AddUpdateMahasiswaPage> {
  var _controllerNokamar = TextEditingController();
  var _controllerNama = TextEditingController();
  var _controllerJurusan = TextEditingController();
  var _controllerTanggalLahir = TextEditingController();
  var _controllerAlamat = TextEditingController();
  File? _foto;
  var _formKey = GlobalKey<FormState>();
  var _scaffoldKey = GlobalKey<ScaffoldState>();
  var _fotoSebelumUpdate;

  Future getFoto() async {
    final pickedFile =
        await ImagePicker().getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _foto = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }
      
  void editMahasiswa(Mahasiswa mahasiswa) async {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        backgroundColor: Colors.black,
        children: [
          Center(child: CircularProgressIndicator()),
          SizedBox(height: 10),
          Center(child: Text('Loading...')),
        ],
      ),
    );
    Future.delayed(Duration(milliseconds: 1000), () {
      Navigator.pop(context);
    });

    if (_foto != null) {
      await http.post(Uri.parse(ApiMahasiswa.URL_DELETE_FOTO), body: {
        'nama': _fotoSebelumUpdate,
      });
      await http.post(Uri.parse(ApiMahasiswa.URL_UPLOAD_FOTO), body: {
        'foto': base64Encode(_foto!.readAsBytesSync()),
        'nama': mahasiswa.foto,
      });
    }
    var response = await http.post(Uri.parse(ApiMahasiswa.URL_EDIT_MAHASISWA),
        body: mahasiswa.toJson());
    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      var message = '';
      if (responseBody['success']) {
        message = 'Berhasil Mengupadate Mahasiswa';
      } else {
        message = 'Gagal Mengupadate Mahasiswa';
      }
      _scaffoldKey.currentState?.showSnackBar(SnackBar(
        content: Text(message),
        duration: Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
      ));
    } else {
      print('Request Error');
    }
  }

  void addMahasiswa(Mahasiswa mahasiswa) async {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        backgroundColor: Colors.white,
        children: [
          Center(child: CircularProgressIndicator()),
          SizedBox(height: 10),
          Center(child: Text('Loading...')),
        ],
      ),
    );
    Future.delayed(Duration(milliseconds: 1000), () {
      Navigator.pop(context);
    });
    var responsenokamar =
        await http.post(Uri.parse(ApiMahasiswa.URL_CEK_KAMAR ), body: {
      'nokamar': mahasiswa.nokamar,
    });
    var check = jsonDecode(responsenokamar.body);
    if (check['ada']) {
      _scaffoldKey.currentState?.showSnackBar(SnackBar(
        content: Text('Kamar Sudah Terdaftar'),
        duration: Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.black,
      ));
    } else {
      await http.post(Uri.parse(ApiMahasiswa.URL_UPLOAD_FOTO), body: {
        'foto': base64Encode(_foto!.readAsBytesSync()),
        'nama': mahasiswa.foto,
      });
      var response = await http.post(Uri.parse(ApiMahasiswa.URL_ADD_MAHASISWA),
          body: mahasiswa.toJson());
      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        var message = '';
        if (responseBody['success']) {
          message = 'Berhasil Menambahkan Mahasiswa';
        } else {
          message = 'Gagal Menambahkan Mahasiswa';
        }
        _scaffoldKey.currentState!.showSnackBar(SnackBar(
          content: Text(message),
          duration: Duration(milliseconds: 1500),
          behavior: SnackBarBehavior.floating,
        ));
      } else {
        print('Request Error');
      }
    }
  }

  @override
  void initState() {
    if (widget.mahasiswa != null) {
      _controllerNokamar.text = widget.mahasiswa!.nokamar ?? '';
      _controllerNama.text = widget.mahasiswa!.nama ?? '';
      _controllerJurusan.text = widget.mahasiswa!.jurusan ?? '';
      _controllerTanggalLahir.text = widget.mahasiswa!.tanggalLahir ?? '';
      _controllerAlamat.text = widget.mahasiswa!.alamat ?? '';
      _fotoSebelumUpdate = widget.mahasiswa!.foto;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.yellow[700],
        title: Text('${widget.type} Mahasiswa'),
        titleSpacing: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                          content: Text('Konfirmasi ${widget.type} Mahasiswa'),
                          actions: [
                            FlatButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Tidak')),
                            FlatButton(
                                onPressed: () => Navigator.pop(context, 'ok'),
                                child: Text('Ya')),
                          ],
                        )).then((value) {
                  if (value == 'ok') {
                    var mahasiswa = Mahasiswa(
                      nokamar: _controllerNokamar.text,
                      nama: _controllerNama.text,
                      jurusan: _controllerJurusan.text,
                      tanggalLahir: _controllerTanggalLahir.text,
                      alamat: _controllerAlamat.text,
                      foto: _foto != null
                          ? _foto!.path.split('/').last
                          : _fotoSebelumUpdate,
                    );
                    if (widget.type == 'Edit') {
                      editMahasiswa(mahasiswa);
                    } else {
                      addMahasiswa(mahasiswa);
                    }
                  }
                });
              }
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 16),
          children: [
            SizedBox(height: 16),
            TextFormField(
              controller: _controllerNokamar,
              enabled: widget.mahasiswa != null ? false : true,
              validator: (value) => value == '' ? 'Tidak boleh kosong' : null,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.yellow, width: 2),
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.yellow, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.yellow, width: 2),
                ),
                labelText: 'No. Kamar',
                hintText: '101',
                labelStyle: TextStyle(color: Colors.yellow),
                suffixIcon: Icon(Icons.vpn_key_rounded, color: Colors.yellow),
              ),
              cursorColor: Colors.yellow,
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _controllerNama,
              validator: (value) => value == '' ? 'Tidak boleh kosong' : null,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.yellow, width: 2),
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.yellow, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.yellow, width: 2),
                ),
                labelText: 'Nama',
                hintText: 'Bambang',
                labelStyle: TextStyle(color: Colors.yellow),
                suffixIcon: Icon(Icons.person, color: Colors.yellow),
              ),
              cursorColor: Colors.yellow,
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _controllerJurusan,
              validator: (value) => value == '' ? 'Tidak boleh kosong' : null,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.yellow, width: 2),
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.yellow, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.yellow, width: 2),
                ),
                labelText: 'Jurusan',
                hintText: 'Teknik Informatika',
                labelStyle: TextStyle(color: Colors.yellow),
                suffixIcon: Icon(Icons.home_work, color: Colors.yellow),
              ),
              cursorColor: Colors.yellow,
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _controllerTanggalLahir,
              validator: (value) => value == '' ? 'Tidak boleh kosong' : null,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.yellow, width: 2),
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.yellow, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.yellow, width: 2),
                ),
                labelText: 'Tanggal Lahir',
                hintText: '2002-02-02',
                labelStyle: TextStyle(color: Colors.yellow),
                suffixIcon: GestureDetector(
                    onTap: () {
                      showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(DateTime.now().year - 50, 1),
                              lastDate: DateTime(DateTime.now().year, 12))
                          .then((value) {
                        _controllerTanggalLahir.text =
                            value!.toIso8601String().substring(0, 10);
                      });
                    },
                    child: Icon(Icons.date_range, color: Colors.yellow)),
              ),
              cursorColor: Colors.yellow,
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _controllerAlamat,
              validator: (value) => value == '' ? 'Tidak boleh kosong' : null,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.yellow, width: 2),
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.yellow, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.yellow, width: 2),
                ),
                labelText: 'Alamat',
                hintText: 'Jl. Kenagangan No.1, Kota Surabaya',
                labelStyle: TextStyle(color: Colors.yellow),
                suffixIcon: Icon(Icons.home, color: Colors.yellow),
              ),
              maxLines: 3,
              cursorColor: Colors.yellow,
            ),
            SizedBox(height: 16),
            Text('Foto'),
            SizedBox(height: 16),
            RaisedButton(
              onPressed: () => getFoto(),
              color: Colors.yellow,
              textColor: Colors.white,
              child: Text('Pilih Foto'),
            ),
            SizedBox(height: 16),
            Center(
              child: SizedBox(
                child: widget.type == 'Edit'
                    ? _foto != null
                        ? Image.file(
                            _foto!,
                            width: 150,
                            height: 150,
                          )
                        : Image.network(
                            '${ApiMahasiswa.URL_FOTO}/${widget.mahasiswa!.foto}',
                            fit: BoxFit.cover,
                            width: 150,
                            height: 150,
                          )
                    : _foto == null
                        ? null
                        : Image.file(
                            _foto!,
                            width: 150,
                            height: 150,
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
