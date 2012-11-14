//
//
//class HashableUri extends Uri implements Hashable {
//
//  int _hashCode;
//
//  HashableUri.fromString(String uri) : super.fromString(uri) {
//    _hashCode = _createHashCode(uri);
//  }
//
//  int hashCode() => _hashCode;
//
//  /*
//  * Blatantly copied from
//  * http://stackoverflow.com/questions/3795400/how-to-calculate-the-hash-code-of-a-string-by-hand-java-related
//  */
//  int _createHashCode(String x) {
//    var hashcode = 0;
//    var MOD = 10007;
//    var shift = 29;
//    for(int i=0;i<x.length;i++){
//        hashcode= ( (shift*hashcode) % MOD + x.charCodeAt(i)) % MOD;
//    }
//    return hashcode;
//  }
//
//
//}
part of crimson_core;
