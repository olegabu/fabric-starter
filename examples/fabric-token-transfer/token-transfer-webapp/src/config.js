import environment from './environment';

export class Config {

  static put(key, val) {
    return localStorage.setItem(key, JSON.stringify(val));
  }

  static get(key) {
    let val = localStorage.getItem(key);
    if(val === 'undefined' || val === null) {
      val = environment[key];
      this.put(key, val);
      return val;
    }
    else {
      return JSON.parse(val);
    }
  }

  static clear() {
    localStorage.clear();
  }

  static getUrl(path) {
    const baseUrl = Config.get('baseUrl');
    if(baseUrl) {
      return path ? `${baseUrl}/${path}` : baseUrl;
    }
    else {
      return path ? `/${path}` : '/';
    }
  }

}
