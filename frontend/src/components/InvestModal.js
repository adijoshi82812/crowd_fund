import { ethers } from "ethers";
import { useState } from "react";
import { useSelector } from "react-redux";
import { Contract } from "../web3";

export const InvestModal = () => {
  const [amount, setAmount] = useState();
  const account = useSelector((state) => state.account);
  const id = useSelector((state) => state.pool_id);

  const handleSendTransaction = async () => {
    try {
      const parsedAmt = ethers.utils.parseEther(amount);
      const res = await Contract.methods.invest_in_pool(id).send({
        from: account,
        value: parsedAmt._hex,
      });
      console.log(res);
    } catch (err) {
      console.log(err);
    }
  };
  return (
    <div className="modal fade" id="invest-modal">
      <div className="modal-dialog">
        <div className="modal-content">
          <div className="modal-header">
            <h4 className="modal-title">Invest modal</h4>
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
              <label htmlFor="amount" className="col-sm-2 col-form-label">
                Amount
              </label>
              <div className="col-sm-10">
                <input
                  type="email"
                  className="form-control"
                  id="amount"
                  placeholder="Enter amount in eth to invest"
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
                handleSendTransaction();
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
