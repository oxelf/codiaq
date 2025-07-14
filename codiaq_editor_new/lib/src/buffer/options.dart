class BufferOptions {
  String filetype = 'text';
  bool readonly = false;
  bool listed = true;
  String buftype = '';
  int tabstop = 4;
  int textwidth = 80;

  Map<String, dynamic> toMap() => {
    'filetype': filetype,
    'readonly': readonly,
    'listed': listed,
    'buftype': buftype,
    'tabstop': tabstop,
    'textwidth': textwidth,
  };
}
