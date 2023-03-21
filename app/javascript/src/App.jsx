import React, { useEffect, useState } from "react";
import Form from "./Form";
import asksApi from "apis/asks";

const App = () => {
  const [question, setQuestion] = useState("")
  const [answer, setAnswer] = useState("")
  const [loading, setLoading] = useState(false)

  const handleSubmit = async event => {
    // debugger
    event.preventDefault();
    console.log(question)
    setLoading(true);
    try {
      const { data } = await asksApi.create({ question });
      setAnswer(data.answer)
      setLoading(false);
    } catch (error) {
      setLoading(false);
    }
  };

  return (

    <div className="max-w-lg mx-auto">
      <h5 class="text-lg font-bold dark:text-white text-center">Ask my Book</h5>
      <hr class="w-48 h-1 mx-auto my-4 bg-gray-400 border-0 rounded md:my-10 dark:bg-gray-700" />
      <p class="text-gray-500 dark:text-gray-400">
        This is an experiment in using AI to make the book's content more accessible. Ask a question and AI'll answer it in real-time:
      </p>

      <Form question={question} answer={answer} setQuestion={setQuestion} loading={loading} handleSubmit={handleSubmit} />
    </div>
  );
};

export default App;
