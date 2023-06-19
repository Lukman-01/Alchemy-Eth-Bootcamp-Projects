import { Alchemy, Network } from 'alchemy-sdk';
import { useEffect, useState } from 'react';

import './App.css';

const settings = {
  apiKey: process.env.REACT_APP_ALCHEMY_API_KEY,
  network: Network.ETH_MAINNET,
};

const alchemy = new Alchemy(settings);

function App() {
  const [blockNumber, setBlockNumber] = useState();
  const [selectedBlock, setSelectedBlock] = useState(null);
  const [selectedTransaction, setSelectedTransaction] = useState(null);
  const [blockDetails, setBlockDetails] = useState(null);
  const [transactionDetails, setTransactionDetails] = useState(null);
  const [address, setAddress] = useState('');

  useEffect(() => {
    async function getBlockNumber() {
      setBlockNumber(await alchemy.core.getBlockNumber());
    }

    getBlockNumber();
  }, []);

  async function getBlock(blockNumber) {
    const block = await alchemy.core.getBlock(blockNumber);
    setBlockDetails(block);
  }

  async function getBlockWithTransactions(blockNumber) {
    const block = await alchemy.core.getBlockWithTransactions(blockNumber);
    setBlockDetails(block);
  }

  async function getTransactionReceipt(transactionHash) {
    const receipt = await alchemy.core.getTransactionReceipt(transactionHash);
    setTransactionDetails(receipt);
  }

  async function getAccountBalance() {
    const balance = await alchemy.core.getBalance(address);
    alert(`Account balance: ${balance}`);
  }

  function handleAddressChange(event) {
    setAddress(event.target.value);
  }

  return (
    <div className="App">
      <h2 className="text-2xl font-bold">Block Explorer</h2>
      <div className="mb-4">Block Number: {blockNumber}</div>

      {blockDetails && (
        <div className="mb-4">
          <h3 className="text-lg font-bold">Block Details</h3>
          <div>
            <strong>Block Number:</strong> {blockDetails.number}
          </div>
          <div>
            <strong>Block Hash:</strong> {blockDetails.hash}
          </div>
          <div>
            <strong>Parent Hash:</strong> {blockDetails.parentHash}
          </div>
          {blockDetails.transactions && blockDetails.transactions.length > 0 && (
            <div>
              <h4 className="text-md font-bold">Transactions</h4>
              <ul>
                {blockDetails.transactions.map((transactionHash) => (
                  <li key={transactionHash}>
                    <button
                      className="text-blue-500 underline"
                      onClick={() => getTransactionReceipt(transactionHash)}
                    >
                      Transaction: {transactionHash}
                    </button>
                  </li>
                ))}
              </ul>
            </div>
          )}
        </div>
      )}

      {transactionDetails && (
        <div className="mb-4">
          <h3 className="text-lg font-bold">Transaction Details</h3>
          <div>
            <strong>Transaction Hash:</strong> {transactionDetails.hash}
          </div>
          <div>
            <strong>From:</strong> {transactionDetails.from}
          </div>
          <div>
            <strong>To:</strong> {transactionDetails.to}
          </div>
          <div>
            <strong>Value:</strong> {transactionDetails.value}
          </div>
        </div>
      )}

      <div>
        <h3 className="text-lg font-bold">Account Balance</h3>
        <input
          type="text"
          value={address}
          onChange={handleAddressChange}
          placeholder="Enter address"
          className="border border-gray-400 rounded px-2 py-1"
        />
        <button
          className="bg-blue-500 hover:bg-blue-600 text-white font-bold py-2 px-4 rounded"
          onClick={getAccountBalance}
        >
          Check Balance
        </button>
      </div>

      {blockNumber && (
        <div>
          <h3 className="text-lg font-bold">Blocks</h3>
          <ul>
            {[...Array(3)].map((_, index) => {
              const block = blockNumber - index;
              return (
                <li key={block}>
                  <button
                    className="text-blue-500 underline mr-2"
                    onClick={() => getBlock(block)}
                  >
                    Block {block}
                  </button>
                  <button
                    className="text-blue-500 underline"
                    onClick={() => getBlockWithTransactions(block)}
                  >
                    Block {block} with Transactions
                  </button>
                </li>
              );
            })}
          </ul>
        </div>
      )}
    </div>
  );
}

export default App;
