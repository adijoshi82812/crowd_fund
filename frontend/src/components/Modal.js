export const Modal = () => {
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
              <label for="fund_name" className="col-sm-2 col-form-label">
                Name
              </label>
              <div className="col-sm-10">
                <input
                  type="email"
                  className="form-control"
                  id="fund_name"
                  placeholder="Enter name for your fund"
                />
              </div>
            </div>

            <div className="form-group row">
              <label for="amount" className="col-sm-2 col-form-label">
                Amount
              </label>
              <div className="col-sm-10">
                <input
                  type="email"
                  className="form-control"
                  id="amount"
                  placeholder="Enter amount in eth"
                />
              </div>
            </div>
          </div>
          <div className="modal-footer justify-content-between">
            <button type="button" className="btn btn-primary">
              Sign Message
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};
