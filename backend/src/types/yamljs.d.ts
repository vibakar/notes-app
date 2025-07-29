declare module "yamljs" {
  const yaml: {
    load(path: string): any;
  };
  export default yaml;
}
