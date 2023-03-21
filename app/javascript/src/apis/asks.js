import axios from "axios";

const list = () => axios.get("/products");

const create = payload =>
  axios.post("/asks", {
    ask: payload,
  });

const asksApi = {
  create,
};

export default asksApi;

