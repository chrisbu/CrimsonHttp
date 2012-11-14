part of crimson_core;


/// Contains the list of handlers that will be called in turn.
class _CrimsonHandlerList<E extends CrimsonHandler> implements CrimsonHandlerList<CrimsonHandler> {

  /// Rather than extending ListXYZ (because we can't extend the List<X> interface
  /// directly as it's an interface), we'll instead use an internal list, and
  /// pass all the methods that would be overrideen to that list.
  final Map<String,CrimsonHandler> _internalMap;

  final CrimsonHttpServer _server;

  _CrimsonHandlerList(CrimsonHttpServer owner) :
    _internalMap = new LinkedHashMap<String,CrimsonHandler>(),
    _server = owner
   {
      //intentionally blank.
   }

  /// Add the handler and return the list to allow method chaining.
  CrimsonHandlerList add(CrimsonHandler handler) {
    if (handler == null) {
      throw new ArgumentError("[handler] cannot be null");
    }

    _internalMap[handler.NAME] = handler;
    handler.server = _server;
    return this;
  }

  CrimsonHandlerList addEndpoint(CrimsonEndpoint endpoint) => add(endpoint);
  CrimsonHandlerList addFilter(CrimsonFilter filter) => add(filter);

  CrimsonHandler operator[] (String key) {
    return _internalMap[key];
  }


  /* Override List implementation */
//  void addAll(Collection collection) => _internalList.addAll(collection);
//  void forEach(void f(E element)) => _internalList.forEach(f);
//  Collection map(f(CrimsonHandler)) => _internalList.map(f);
//  Collection filter(bool f(CrimsonHandler)) => _internalList.filter(f);
//  bool every(bool f(CrimsonHandler)) => _internalList.every(f);
//  bool some(bool f(CrimsonHandler)) => _internalList.some(f);
//  bool isEmpty() => _internalList.isEmpty();
    Iterator iterator() => _internalMap.values.iterator();
//  CrimsonHandler operator[](int i) => _internalList[i];
//  void operator []=(int index,value) => _internalList[index] = value;
//  int get length() =>  _internalList.length;
//  void addLast(CrimsonHandler value) => _internalList.addLast(value);
//  void sort(int compare(CrimsonHandler, CrimsonHandler)) => _internalList.sort(compare);
//  int indexOf(E element, [int start]) => _internalList.indexOf(element, start);
//  int lastIndexOf(E element, [int start]) => _internalList.lastIndexOf(element, start);
//  void clear() => _internalList.clear();
//  CrimsonHandler removeLast() => _internalList.removeLast();
//  void remove(int start, int l) => _internalList.removeRange(start, l);
//  CrimsonHandler last() => _internalList.last();
//  List getRange(int start, int l) => _internalList.getRange(start, l);
//  void setRange(int start, int l, List from, [int startFrom]) => _internalList.setRange(start, l, from, startFrom);
//  void removeRange(int start, int l) => _internalList.removeRange(start, l);
//  void insertRange(int start, int l, [CrimsonHandler initialValue]) => _internalList.insertRange(start, l, initialValue);
}
