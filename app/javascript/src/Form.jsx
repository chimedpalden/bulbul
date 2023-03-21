import React from "react";

const Form = ({ question, answer, setQuestion, loading, handleSubmit }) => {
  const handleClick = e => {
    return null;
  };

  return (
    <form onSubmit={handleSubmit}>
      <div className="mt-6">
        <label for="large-input" className="block mb-2 text-sm font-medium text-gray-900 dark:text-white">Large input</label>

        <div className="mt-1 rounded-md shadow-sm">
          <input 
            type="text" 
            id="large-input" 
            required={true}
            value={question}
            className="block w-full p-4 text-gray-900 border border-gray-300 rounded-lg bg-gray-50 sm:text-md focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500" 
            placeholder="Todo Title (Max 50 Characters Allowed)"
            onChange={e => setQuestion(e.target.value)}
          />
        </div>
      </div>

      <div className="mt-6">
        <p class="mb-3 font-light text-gray-600 dark:text-gray-500">
          {answer && `Answer: ${answer}`}
        </p>
      </div>
      <div className="mt-6">
        <button
          type="submit"
          onClick={handleClick}
          disabled={false}
          className={"bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4"}
        >
          {loading ? "Asking...." : "Ask question"}
        </button>
      </div>
    </form>
  );
};

export default Form;
