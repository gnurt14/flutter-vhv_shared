part of '../helper.dart';

Map _getComponent(String type){
  switch(type){
    case 'account':
      if(account.isLogin() && !empty(account['components'])){
        if(account['components'] is Map){
          return account['components'];
        }
        if(account['components'] is List){
          final components = checkType<Map>(Setting().get('components'))??{};
          final Map c = {};
          if(components.isNotEmpty){
            components.forEach((key, value) {
              ((account['components'] is Map)?account['components'].values.toList():account['components']).forEach((e){
                if(e == value){
                  c.addAll({
                    key: value
                  });
                }
              });
            });
          }
          return c;
        }

      }
      return {};
    default:
      return checkType<Map>(Setting().get('components'))??{};
  }
}

bool hasComponent(String component, [String? type]) {
  if (_getComponent(type??'').containsKey(component)) {
    return true;
  } else {
    return false;
  }
}

bool hasAction(String action, [String? groupId]) {
  if (!empty(account.isOwner())) return true;
  if (empty(groupId)) groupId = account['cmsGroupId'];
  if (!empty(groupId) &&
      !empty(account['accountActions']) &&
      account['accountActions'] is Map) {
    if(action.contains(',')){
      bool hasAction = false;
      action.split(',').forEach((element) {
        if(inArray(element, account['accountActions'][groupId])){
          hasAction = true;
        }
      });
      return hasAction;
    }
    if (account['accountActions'].containsKey(groupId)) {
      return inArray(action, account['accountActions'][groupId]);
    }
  }
  return false;
}

bool hasRole(dynamic role, [String linkId = '']){
  assert(role is String || role is List || role == null);
  if(parseInt(AppInfo['expiredTime']) < time() && account.userId != '1'){
    return false;
  }
  if(empty(linkId)){
    linkId = account['groupId'];
  }else if(linkId == 'cms'){
    linkId = AppInfo.cmsGroupId;
  }else if(linkId == 'mygroups') {
    linkId = account.accountLinks.keys.join(',');
  }
  if (account.isOwner()
      && (
          empty(linkId)
              || linkId != account['groupId']
              || (linkId == AppInfo.cmsGroupId && empty(AppInfo['powerGrantPrivillege']))
              || (linkId != AppInfo.cmsGroupId)
      )) {
    return true;
  }
  if (empty(linkId)) {
    return false;
  }
  List links = linkId.split(',').map((s) => s.trim()).toList();
  List roles = role is List ? role : role.toString().split(',').where((r) =>
  r.isNotEmpty).toList();
  if (roles.isNotEmpty && !roles.contains('Admin')) {
    roles.add('Admin');
  }
  if (roles.contains('Member') || roles.contains('Content')) {
    roles.addAll(['Content', 'Manager']);
  }
  bool ok = false;
  for (String linkId in links) {
    if (account.accountLinks.containsKey(linkId)) {
      var linkRoles = account.accountLinks[linkId]['roles'] as List;
      if (roles.isEmpty || roles.any((r) => linkRoles.contains(r))) {
        ok = true;
      }
    } else if (linkId.startsWith('Account')) {
      for (var accountLink in account.accountLinks.values) {
        if (linkId.startsWith(accountLink['linkType']) &&
            (roles.isEmpty ||
                roles.any((r) => accountLink['roles'].contains(r)))) {
          ok = true;
          break;
        }
      }
    }
  }
  return ok;
}