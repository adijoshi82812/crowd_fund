import { useState } from "react";
import { useSelector } from "react-redux";
import { Contract } from "../web3";

export const Modal = (preload) => {
  /* global BigInt */
  const [name, setName] = useState();
  const [amount, setAmount] = useState();
  const account = useSelector((state) => state.account);

  const sendTransaction = async () => {
    try {
      const unique_name = await Contract.methods.unique_names(name).call();
      if (!unique_name) {
        const has_user_created_pool = await Contract.methods
          .has_user_created_pool(account)
          .call();
        if (!has_user_created_pool) {
          const result = await Contract.methods
            .create_fund_request(name, BigInt(amount * Math.pow(10, 18)))
            .send({ from: account });
          window.location.reload(false);
          return result;
        } else {
          throw new Error("You have already created a request");
        }
      } else {
        throw new Error("Try a different name");
      }
    } catch (err) {
      alert(err.message);
    }
  };

  return (
    <div className="modal fade" id="modal-default">
      <div className="modal-dialog">
        <div className="modal-content">
          <div className="modal-header">
            <h4 className="modal-title">Request a fund approval</h4>
            <button
              type="button"
              className="close"
              data-dismiss="modal"
              aria-label="Close"
            >
              <span aria-hidden="true">&times;</span>
            </button>
          </div>
          <div className="modal-body">
            <div className="form-group row">
              <label htmlFor="fund_name" className="col-sm-2 col-form-label">
                Name
              </label>
              <div className="col-sm-10">
                <input
                  type="email"
                  className="form-control"
                  id="fund_name"
                  placeholder="Enter name for your fund"
                  onChange={(e) => {
                    e.preventDefault();
                    setName(e.target.value);
                  }}
                />
              </div>
            </div>

            <div className="form-group row">
              <label htmlFor="amount" className="col-sm-2 col-form-label">
                Amount
              </label>
              <div className="col-sm-10">
                <input
                  type="email"
                  className="form-control"
                  id="amount"
                  placeholder="Enter amount in eth"
                  onChange={(e) => {
                    e.preventDefault();
                    setAmount(e.target.value);
                  }}
                />
              </div>
            </div>
          </div>
          <div className="modal-footer justify-content-between">
            <button
              type="button"
              className="btn btn-primary"
              onClick={(e) => {
                e.preventDefault();
                sendTransaction();
              }}
            >
              Sign Message
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};
